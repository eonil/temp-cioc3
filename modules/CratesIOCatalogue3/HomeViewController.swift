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
    func render() {
        installer.installIfNeeded {
            collectionView.backgroundColor = UIColor.whiteColor()
            collectionView.registerClass(ErrorCell.self, forCellWithReuseIdentifier: CellTypeID.Error.rawValue)
            collectionView.registerClass(CrateSummaryCell.self, forCellWithReuseIdentifier: CellTypeID.CrateSummary.rawValue)
            collectionView.dataSource = self
            collectionView.delegate = self
            view.addSubview(collectionView)
        }
        collectionView.frame = view.bounds
        collectionView.reloadData()
    }
}
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return SectionID.all.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch SectionID.all[section] {
        case .NewCrates:        return driver.state.navigation.home.newItems.count
        case .MostDownloaded:   return driver.state.navigation.home.popularItems.count
        case .JustUpdated:      return driver.state.navigation.home.justUpdatedItems.count
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellTypeID.CrateSummary.rawValue, forIndexPath: indexPath) as? CrateSummaryCell else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(CellTypeID.Error.rawValue, forIndexPath: indexPath)
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CrateSummaryCell else { return }
        cell.crateSummary = driver.state.database.crateSummaries[getCrateIDFor(indexPath)]
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let crateID = getCrateIDFor(indexPath)
        driver.dispatch(DriverCommand.UserInterface(Action.PushCrateDetail(crateID)))
    }

    private func getCrateIDFor(indexPath: NSIndexPath) -> CrateID {
        switch SectionID.all[indexPath.section] {
        case .NewCrates:        return driver.state.navigation.home.newItems[indexPath.item]
        case .MostDownloaded:   return driver.state.navigation.home.popularItems[indexPath.item]
        case .JustUpdated:      return driver.state.navigation.home.justUpdatedItems[indexPath.item]
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










