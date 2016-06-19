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

private enum TableCell: String {
    case crate
    case error
}
private extension TableCell {
    func getRowHeight() -> CGFloat {
        return 96
    }
}

final class HomeViewController2: UIViewController, Renderable, DriverAccessible {
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private var installer = ViewInstaller()
    private var currentStateVersion: Version?

    func render() {
        installer.installIfNeeded {
            tableView.registerClass(CrateCell.self, forCellReuseIdentifier: TableCell.crate.rawValue)
            tableView.registerClass(ErrorCell.self, forCellReuseIdentifier: TableCell.error.rawValue)
            tableView.dataSource = self
            tableView.delegate = self
            view.addSubview(tableView)
        }
        if currentStateVersion != state.navigation.home.version {
            tableView.reloadData()
            currentStateVersion = state.navigation.home.version
        }
        renderLayoutOnly()
    }
    func renderLayoutOnly() {
        tableView.frame = view.bounds
    }
}

extension HomeViewController2 {
    private func crateIDFor(section section: TableSection, row: Int) -> CrateID {
        switch section {
        case .newCrates:        return state.navigation.home.newItems[row]
        case .justUpdated:      return state.navigation.home.justUpdatedItems[row]
        case .mostDownloaded:   return state.navigation.home.mostDownloadedItems[row]
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
        case .newCrates:        return state.navigation.home.newItems.count
        case .justUpdated:      return state.navigation.home.justUpdatedItems.count
        case .mostDownloaded:   return state.navigation.home.mostDownloadedItems.count
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
        guard let cell = tableView.dequeueReusableCellWithIdentifier(TableCell.crate.rawValue, forIndexPath: indexPath) as? CrateCell else {
            return tableView.dequeueReusableCellWithIdentifier(TableCell.error.rawValue, forIndexPath: indexPath)
        }
        let crateID = crateIDFor(section: TableSection.all[indexPath.section], row: indexPath.row)
        assert(state.database.crates[crateID] != nil)
        cell.state = state.database.crates[crateID]?.basics
        return cell
    }
    @objc
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let crateID = crateIDFor(section: TableSection.all[indexPath.section], row: indexPath.row)
        driver.operation.pushCrateInspectorFor(crateID)
    }
}

private final class CrateCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let versionLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var installer = ViewInstaller()
    var state: CrateStateBasics? {
        didSet {
            render()
        }
    }
    func render() {
        installer.installIfNeeded {
            contentView.addSubview(nameLabel)
            contentView.addSubview(versionLabel)
            contentView.addSubview(descriptionLabel)
            descriptionLabel.numberOfLines = 0
        }
        nameLabel.attributedText = state?.name.attributed().stylizedSilently(.crateList(.itemName))
        versionLabel.attributedText = state?.version.attributed().stylizedSilently(.crateList(.itemVersion))
        descriptionLabel.attributedText = state?.description?.attributed().stylizedSilently(.crateList(.itemDescription))
        renderLayoutOnly()
    }
    private func renderLayoutOnly() {
        let	LARGE_GAP = CGFloat(20)
        let	SMALL_GAP = CGFloat(10)

        let nameSize = nameLabel.sizeThatFits(CGSize.zero)
        let versionSize = versionLabel.sizeThatFits(CGSize.zero)
        let box = contentView.bounds.toBox().toSilentBox()
        let (_, contentBox, _) = box.splitInX(LARGE_GAP, 100%, LARGE_GAP).center.splitInY(SMALL_GAP, 100%, SMALL_GAP)
        let (topBox, _, bottomBox) = contentBox.splitInY(max(nameSize.height, versionSize.height), SMALL_GAP, 100%)
        let (nameBox, _, versionBox) = topBox.splitInX(100%, SMALL_GAP, versionSize.width)

        let descriptionSize = descriptionLabel.sizeThatFits(bottomBox.toCGRect().size)
        let (descriptionBox, _, _) = bottomBox.splitInY(descriptionSize.height, 0%, 0%)

        nameLabel.frame = nameBox.toCGRect()
        versionLabel.frame = versionBox.toCGRect()
        descriptionLabel.frame = descriptionBox.toCGRect()
    }
    private override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
}

private final class ErrorCell: UITableViewCell {
}








