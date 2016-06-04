//
//  DriverCommand.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

enum DriverCommand {
    case WaitForDuration(duration: NSTimeInterval)
    case UserInterface(Action)
}