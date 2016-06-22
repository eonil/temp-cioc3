//
//  Renderer.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit

final class Renderer: Renderable, DriverAccessible {
    private let main: MainWindowController
    private var renderCount = 0

    init() {
//        UIView.appearance().tintColor = Style.defaultTintColor
        UISegmentedControl.appearance().tintColor = Style.weakTintColor
//        UIView.appearance().tintColor					=	Palette.Color.defaultTint
        UINavigationBar.appearance().tintColor			=	Style.defaultTintColor
        UIWindow.appearance().tintColor					=	Style.defaultTintColor
        UIAlertView.appearance().tintColor				=	Style.defaultTintColor
        UIActivityIndicatorView.appearance().tintColor	=	Style.defaultTintColor
//        UISearchBar.appearance().barTintColor			=	UIColor.whiteColor()
//        UIButton.appearance().backgroundColor			=	Palette.Color.Button.background
//        UIButton.appearance().tintColor					=	Palette.Color.Button.text


        // Make sure that any UI components to be instantiated after global appearance set up.
        main = MainWindowController()
    }
    func render(state: UserInteractionState) {
        renderCount += 1
        debugLog("renderCount = \(renderCount)")
        main.render(state)
    }
}
protocol Renderable {
    func render(state: UserInteractionState)
}
