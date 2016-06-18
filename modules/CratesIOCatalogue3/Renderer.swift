//
//  Renderer.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit

final class Renderer: Renderable, DriverAccessible {
    private let main = MainWindowController()
    func render() {
        main.render()
    }
}
protocol Renderable {
    func render()
}
