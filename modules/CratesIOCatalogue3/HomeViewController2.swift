//
//  HomeViewController2.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/16.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit
import BoltsSwift
import EonilToolbox

private enum TableSection {
    case newCrates
    case justUpdated
    case mostDownloaded
}
private extension TableSection {
    static let all = [.newCrates, .justUpdated, .mostDownloaded] as [TableSection]
    private func getLabel() -> String {
        switch self {
        case .newCrates:        return "New Crates"
        case .justUpdated:      return "Just Updated"
        case .mostDownloaded:   return "Most Downloaded"
        }
    }
}
private struct LocalState {
    var homeState = HomeState()
    var database = DatabaseState()
}

private enum TableCell: String {
    case crate
    case error
}
private extension TableCell {
    func getRowHeight() -> CGFloat {
        return CrateSummaryCell.designedHeight
    }
}

/// The first screen.
final class HomeViewController2: UIViewController, Renderable, DriverAccessible {
    private let searchController = UISearchController(searchResultsController: HomeSearchResultViewController())
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let reloadingRefresh = UIRefreshControl()
    private let creditAttributionView = CreditAttributionView()
    private var installer = ViewInstaller()
    private var localState = LocalState()

    private func getSearchResultViewController() -> HomeSearchResultViewController? {
        return searchController.searchResultsController as? HomeSearchResultViewController
    }
    func render(newState: UserInteractionState) {
        getSearchResultViewController()?.render(newState)
        creditAttributionView.render()
        installer.installIfNeeded {
            navigationItem.titleView = searchController.searchBar
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.placeholder = "crates.io"
            searchController.searchBar.autocapitalizationType = .None
            searchController.searchBar.autocorrectionType = .No
            searchController.searchResultsUpdater = self
            definesPresentationContext = true

            view.backgroundColor = tableView.backgroundColor
            view.addSubview(tableView)
            tableView.registerClass(CrateSummaryCell.self, forCellReuseIdentifier: TableCell.crate.rawValue)
            tableView.registerClass(ErrorCell.self, forCellReuseIdentifier: TableCell.error.rawValue)
            tableView.dataSource = self
            tableView.delegate = self

            // `UIRefreshControl` controls its frame itself on a table view.
            // So do not try to set its frame yourself.
            tableView.addSubview(reloadingRefresh)
            reloadingRefresh.addTarget(self, action: #selector(EONIL_didChangeValue(_:)), forControlEvents: .ValueChanged)
        }
        if localState.database.version != newState.database.version {
            localState.database = newState.database
        }
        if localState.homeState.version != newState.navigation.home.version {
            localState.homeState = newState.navigation.home
            if localState.homeState.summary.isTransferring {
//                reloadingRefresh.beginRefreshing()
            }
            else {
                reloadingRefresh.endRefreshing()
            }

            tableView.reloadData()
//            func a() {
//                tableView.alpha = (localState.homeState.summary.isTransferring) ? 0 : 1
//            }
//            UIView.animateWithDuration(0.5) { a() }
        }
    }
    func renderLayoutOnly() {
        tableView.frame = view.bounds

        // Resize attribution.
        tableView.tableFooterView = nil
        creditAttributionView.frame.size = creditAttributionView.sizeThatFits(CGSize(width: view.bounds.size.width, height: CGFloat.max))
        tableView.tableFooterView = creditAttributionView
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        renderLayoutOnly()
    }
}

extension HomeViewController2 {
    @objc
    private func EONIL_didChangeValue(_: NSObject?) {
        driver.operation.reloadHome().continueWithTask { [weak self] (task: Task<()>) -> Task<()> in
            guard let S = self else { return task }
            // This might possibly can be wrongly ends the animation.
            // Anyway, I think that's not really critical here...
            S.reloadingRefresh.endRefreshing()
            return task
        }
    }
}


extension HomeViewController2: UITableViewDataSource, UITableViewDelegate {
    @objc
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return localState.homeState.summary.result == nil ? 0 : TableSection.all.count
    }
    @objc
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let summary = localState.homeState.summary.result else { return 0 }
        switch TableSection.all[section] {
        case .newCrates:        return summary.newItems.count
        case .justUpdated:      return summary.justUpdatedItems.count
        case .mostDownloaded:   return summary.mostDownloadedItems.count
        }
    }
    @objc
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TableSection.all[section].getLabel()
    }
    @objc
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch TableSection.all[indexPath.section] {
        case .newCrates:        return TableCell.crate.getRowHeight()
        case .justUpdated:      return TableCell.crate.getRowHeight()
        case .mostDownloaded:   return TableCell.crate.getRowHeight()
        }
    }
    @objc
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let crateID = crateIDFor(section: TableSection.all[indexPath.section], row: indexPath.row) else {
            return tableView.dequeueReusableCellWithIdentifier(TableCell.error.rawValue, forIndexPath: indexPath)
        }
        guard let cell = tableView.dequeueReusableCellWithIdentifier(TableCell.crate.rawValue, forIndexPath: indexPath) as? CrateSummaryCell else {
            return tableView.dequeueReusableCellWithIdentifier(TableCell.error.rawValue, forIndexPath: indexPath)
        }
        assert(localState.database.crates[crateID] != nil)
        cell.render(localState.database.crates[crateID]?.basics)
        return cell
    }
    @objc
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let crateID = crateIDFor(section: TableSection.all[indexPath.section], row: indexPath.row) else { return }
        driver.operation.pushCrateInspectorFor(crateID)
    }
}
extension HomeViewController2 {
    private func crateIDFor(section section: TableSection, row: Int) -> CrateID? {
        guard let summary = localState.homeState.summary.result else { return nil }
        switch section {
        case .newCrates:        return summary.newItems[row]
        case .justUpdated:      return summary.justUpdatedItems[row]
        case .mostDownloaded:   return summary.mostDownloadedItems[row]
        }
    }
}

private final class ErrorCell: UITableViewCell {
}

extension HomeViewController2: UISearchResultsUpdating {
    @objc
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let q = searchController.searchBar.text ?? ""
        driver.operation.search(q)
    }
}







