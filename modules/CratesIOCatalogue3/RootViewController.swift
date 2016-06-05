//
//  RootViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit
import EonilToolbox

final class RootViewController: UINavigationController, DriverAccessible, Renderable {
    private let home = HomeViewController()
    private let search = SearchViewController()
    private var installer = ViewInstaller()
    private var inTransition = false
    private var crateDetailStack = [CrateDetailViewController]()
    private var currentState: NavigationState?

    func render() {
        installer.installIfNeeded { 
            self.delegate = self
        }
        let needsAnimation = (view.window != nil)
        renderNaivgationStateOnlyAnimated(needsAnimation)
    }
    private func renderNaivgationStateOnlyAnimated(animated: Bool) {
        guard inTransition == false else { return }
//        switch driver.state.navigation.mode {
//        case .Browse:
//        case .Search:
//        }

        if driver.state.navigation.detailStack == [] {
            setViewControllers([home], animated: animated)
        }
        else {
            if driver.state.navigation.detailStack != (currentState?.detailStack ?? []) {
                func makeCrateDetailVC(crateID: CrateID) -> CrateDetailViewController {
                    let vc = CrateDetailViewController()
                    vc.crateID = crateID
                    return vc
                }
                crateDetailStack = driver.state.navigation.detailStack.map({ makeCrateDetailVC($0) })
                setViewControllers([home] + crateDetailStack, animated: animated)
                
            }
        }
        currentState = driver.state.navigation
    }
    private func scanNavigationStateOnly() {
        var navigationState = driver.state.navigation
        let newStack = viewControllers[1..<viewControllers.count].flatMap({ $0 as? CrateDetailViewController }).flatMap({ $0.crateID })
        navigationState.detailStack = newStack
        driver.dispatch(DriverCommand.UserInterface(Action.ReconfigureNavigation(navigationState)))
    }
}

extension RootViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        inTransition = true
    }
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        inTransition = false


        if driver.state.navigation.detailStack == (currentState?.detailStack ?? []) {
            // Navigation has not been changed.
            // Whatever user did, it need to be reflected.
            // Follow view state.
            scanNavigationStateOnly()
        }
        else {
            // Navigation has been changed while transition.
            // Whatever user did, it's been invalidated.
            // Follow new state.
            renderNaivgationStateOnlyAnimated(animated)
        }
    }
}






