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
    func render() {
        mainWindow.screen = UIScreen.mainScreen()
        mainWindow.frame = UIScreen.mainScreen().bounds
        mainWindow.rootViewController = root
        mainWindow.makeKeyAndVisible()
        root.renderRecursively()
    }
}

private extension UIViewController {
    func renderRecursively() {
        if let renderable = self as? Renderable {
            renderable.render()
        }
        for child in childViewControllers {
            child.renderRecursively()
        }
    }
}