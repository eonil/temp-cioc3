//
//  HomeViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit
import EonilToolbox

private enum SectionID {
    case NewCrates
    case MostDownloaded
    case JustUpdated

    static let all: [SectionID] = [.NewCrates, .MostDownloaded, .JustUpdated]
}
private enum CellTypeID: String {
    case Error
    case CrateSummary
}

final class HomeViewController: UIViewController, Renderable, DriverAccessible {
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var installer = ViewInstaller()
    private var currentVersion: Version?

    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    func render() {
        installer.installIfNeeded {
            collectionView.backgroundColor = UIColor.whiteColor()
            collectionView.registerClass(ErrorCell.self, forCellWithReuseIdentifier: CellTypeID.Error.rawValue)
            collectionView.registerClass(CrateSummaryCell.self, forCellWithReuseIdentifier: CellTypeID.CrateSummary.rawValue)
            collectionView.dataSource = self
            collectionView.delegate = self
            view.addSubview(collectionView)
        }
        renderLayoutOnly()
        renderSummaryListInformationOnly()
    }
    func renderLayoutOnly() {
        collectionView.frame = view.bounds
        if let flowLayout = flowLayout {
            flowLayout.itemSize = CGSize(width: collectionView.bounds.width, height: 44)
        }
    }
    func renderSummaryListInformationOnly() {
        guard currentVersion != state.navigation.home.version else { return }
        collectionView.reloadData()
        currentVersion = state.navigation.home.version
    }
}
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    @objc
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return SectionID.all.count
    }
    @objc
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch SectionID.all[section] {
        case .NewCrates:        return state.navigation.home.newItems.count
        case .MostDownloaded:   return state.navigation.home.popularItems.count
        case .JustUpdated:      return state.navigation.home.justUpdatedItems.count
        }
    }
    @objc
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellTypeID.CrateSummary.rawValue, forIndexPath: indexPath) as? CrateSummaryCell else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(CellTypeID.Error.rawValue, forIndexPath: indexPath)
        }
        return cell
    }
    @objc
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CrateSummaryCell else { return }
        let crateID = getCrateIDFor(indexPath)
        cell.crateSummary = state.database.crates[crateID]?.summary
    }
    @objc
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let crateID = getCrateIDFor(indexPath)
        driver.userInteraction.dispatch { state in
            state.navigation.pushCrateDetail(crateID)
        }
    }

    private func getCrateIDFor(indexPath: NSIndexPath) -> CrateID {
        switch SectionID.all[indexPath.section] {
        case .NewCrates:        return state.navigation.home.newItems[indexPath.item]
        case .MostDownloaded:   return state.navigation.home.popularItems[indexPath.item]
        case .JustUpdated:      return state.navigation.home.justUpdatedItems[indexPath.item]
        }
    }
}

private final class ErrorCell: UICollectionViewCell {
}
private final class CrateSummaryCell: UICollectionViewCell {
    var crateSummary: CrateSummaryState? {
        didSet { render() }
    }
    func render() {
        contentView.backgroundColor = UIColor.magentaColor()
    }
}










