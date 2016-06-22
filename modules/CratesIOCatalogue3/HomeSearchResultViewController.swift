//
//  HomeSearchResultViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/20.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit
import EonilToolbox

private enum CellTypeID: String {
    case error
    case crateSummary
}

private struct LocalState {
    var matchingCrateSummaries = [CrateSummary]()
}
private typealias CrateSummary = (id: CrateID, basics: CrateStateBasics?)

final class HomeSearchResultViewController: UIViewController, Renderable {
    private let tableView = UITableView()
    private var installer = ViewInstaller()
    private var localState = LocalState()
    func render(newState: UserInteractionState) {
        downloadAndReduce(newState)
        renderWithLocalState()
    }
    private func downloadAndReduce(newState: UserInteractionState) {
        func getSummary(crateID: CrateID) -> CrateSummary {
            return (crateID, newState.database.crates[crateID]?.basics)
        }
        localState.matchingCrateSummaries = (newState.navigation.search.result.transmission.result ?? []).map(getSummary)
//        debugLog(newState.navigation.search.result.transmission.result)
    }
    private func renderWithLocalState() {
        installer.installIfNeeded {
            view.addSubview(tableView)
            tableView.registerClass(ErrorCell.self, forCellReuseIdentifier: CellTypeID.error.rawValue)
            tableView.registerClass(CrateSummaryCell.self, forCellReuseIdentifier: CellTypeID.crateSummary.rawValue)
            tableView.rowHeight = CrateSummaryCell.designedHeight
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
        }
        tableView.frame = view.bounds
        tableView.reloadData()
    }
}
extension HomeSearchResultViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        renderWithLocalState()
    }
}
extension HomeSearchResultViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localState.matchingCrateSummaries.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(CellTypeID.crateSummary.rawValue, forIndexPath: indexPath) as? CrateSummaryCell else {
            return tableView.dequeueReusableCellWithIdentifier(CellTypeID.error.rawValue, forIndexPath: indexPath)
        }
        let crateBasics = localState.matchingCrateSummaries[indexPath.row].basics
        cell.render(crateBasics)
        return cell
    }
}

private final class ErrorCell: UITableViewCell {
}











