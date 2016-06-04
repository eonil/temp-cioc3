//
//  RootViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit

final class RootViewController: UINavigationController, DriverAccessible {
    private let home = HomeViewController()
    private let search = SearchViewController()
    private var crateDetailStack = [CrateDetailViewController]()

    func render() {
        let needsAnimation = (view.window != nil)
        renderNaivgationStateOnlyAnimated(needsAnimation)
    }
    private func renderNaivgationStateOnlyAnimated(animated: Bool) {
        switch driver.state.navigation.screen {
        case .Home:
            crateDetailStack = []
            setViewControllers([home], animated: animated)

        case .Search:
            crateDetailStack = []
            setViewControllers([home, search], animated: animated)

        case .CrateDetail(let stack):
            func makeCrateDetailVC(crateID: CrateID) -> CrateDetailViewController {
                let vc = CrateDetailViewController()
                vc.crateID = crateID
                return vc
            }
            crateDetailStack = stack.map({ makeCrateDetailVC($0) })
            setViewControllers([home] + crateDetailStack, animated: animated)
        }
    }
}