//
//  CrateDetailViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit

final class CrateDetailViewController: UIViewController, Renderable {
    var crateID: CrateID? {
        didSet {
            render()
        }
    }

    func render() {

    }
}