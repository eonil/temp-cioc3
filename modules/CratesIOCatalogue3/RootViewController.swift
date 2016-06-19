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
    private let home = HomeViewController2()
    private let search = SearchViewController()
    private var crateInspectors = [CrateInspectorViewController]()
    private var installer = ViewInstaller()
    private var inTransition = false
    private var renderedState: NavigationState?

    func render() {
        installer.installIfNeeded { 
            delegate = self
            viewControllers = [home]

//            // http://stackoverflow.com/a/18969823/246776
//            navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//            navigationBar.shadowImage = UIImage()
//            navigationBar.translucent = true
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
        guard state.navigation.version != renderedState?.version else { return }
        let crateInspectionStack = state.navigation.crateInspectorStack
        if crateInspectors.count != crateInspectionStack.count {
            while crateInspectors.count < crateInspectionStack.count {
                let vc = CrateInspectorViewController()
                vc.indexInCrateInspectionStateStack = crateInspectors.count
                crateInspectors.append(vc)
            }
            while crateInspectors.count > crateInspectionStack.count {
                crateInspectors.removeLast()
            }
            setViewControllers([home] + crateInspectors, animated: animated)
        }
        renderedState = state.navigation
    }
    private func scanNavigationStateOnly() {
        // `UINavigationController` can pop a view-controller only by user-interaction.
        // Anyway popping-only, no pushing.
        let crateInspectorCount = max(0, viewControllers.count - 1)
        while crateInspectors.count > crateInspectorCount {
            crateInspectors.removeLast()
        }
        driver.userInteraction.dispatchTransaction { state in
            while state.navigation.crateInspectorStack.count > crateInspectorCount {
                state.navigation.popTopCrateInspector()
            }
        }
    }
}

extension RootViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        inTransition = true
    }
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        inTransition = false
        scanNavigationStateOnly()
    }
}






