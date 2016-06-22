//
//  MainWindowController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit

final class MainWindowController: Renderable {
    private let mainWindow = UIWindow()
    private let root = RootViewController()
    init() {
    }
    func render(state: UserInteractionState) {
        mainWindow.screen = UIScreen.mainScreen()
        mainWindow.frame = UIScreen.mainScreen().bounds
        mainWindow.rootViewController = root
        mainWindow.makeKeyAndVisible()
        root.renderRecursively(state)
    }
}

private extension UIViewController {
    func renderRecursively(state: UserInteractionState) {
        if let renderable = self as? Renderable {
            renderable.render(state)
        }
        for child in childViewControllers {
            child.renderRecursively(state)
        }
    }
}