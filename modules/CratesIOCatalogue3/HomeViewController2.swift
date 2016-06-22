//
//  HomeViewController2.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/16.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit
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
        return 96
    }
}

/// The first screen.
final class HomeViewController2: UIViewController, Renderable, DriverAccessible {
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let searchController = UISearchController(searchResultsController: HomeSearchResultViewController())
    private var installer = ViewInstaller()
    private var localState = LocalState()

    func render(state: UserInteractionState) {
        installer.installIfNeeded {
            view.addSubview(tableView)
            tableView.registerClass(CrateSummaryCell.self, forCellReuseIdentifier: TableCell.crate.rawValue)
            tableView.registerClass(ErrorCell.self, forCellReuseIdentifier: TableCell.error.rawValue)
            tableView.dataSource = self
            tableView.delegate = self
            navigationItem.titleView = searchController.searchBar
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.placeholder = "crates.io"
            searchController.searchResultsUpdater = self
            definesPresentationContext = true
        }
        if localState.homeState.version != state.navigation.home.version {
            localState.homeState = state.navigation.home
            tableView.reloadData()
        }
        if localState.database.version != state.database.version {
            localState.database = state.database
        }
        renderLayoutOnly()
    }
    func renderLayoutOnly() {
        tableView.frame = view.bounds
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        renderLayoutOnly()
    }
}

extension HomeViewController2 {
    private func crateIDFor(section section: TableSection, row: Int) -> CrateID {
        switch section {
        case .newCrates:        return localState.homeState.newItems[row]
        case .justUpdated:      return localState.homeState.justUpdatedItems[row]
        case .mostDownloaded:   return localState.homeState.mostDownloadedItems[row]
        }
    }
}

extension HomeViewController2: UITableViewDataSource, UITableViewDelegate {
    @objc
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.all.count
    }
    @objc
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection.all[section] {
        case .newCrates:        return localState.homeState.newItems.count
        case .justUpdated:      return localState.homeState.justUpdatedItems.count
        case .mostDownloaded:   return localState.homeState.mostDownloadedItems.count
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
        guard let cell = tableView.dequeueReusableCellWithIdentifier(TableCell.crate.rawValue, forIndexPath: indexPath) as? CrateSummaryCell else {
            return tableView.dequeueReusableCellWithIdentifier(TableCell.error.rawValue, forIndexPath: indexPath)
        }
        let crateID = crateIDFor(section: TableSection.all[indexPath.section], row: indexPath.row)
        assert(localState.database.crates[crateID] != nil)
        cell.state = localState.database.crates[crateID]?.basics
        return cell
    }
    @objc
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let crateID = crateIDFor(section: TableSection.all[indexPath.section], row: indexPath.row)
        driver.operation.pushCrateInspectorFor(crateID)
    }
}
private final class ErrorCell: UITableViewCell {
}

extension HomeViewController2: UISearchResultsUpdating {
    @objc
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}







