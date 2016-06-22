
//
//  Driver.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import BoltsSwift
import EonilToolbox

/// Application master control.
///
/// Driver just dispatches messages to appropriate services and does nothing else.
///
/// - Note: I still am not sure on this.
///         1. Collect all messages and dispatch them globally serially.
///         2. Expose services directly and let subsystems to dispatch to them directly.
///             So messages can be dispatched paralelly.
///
///
final class Driver {
    private static let theDriver = Driver()

    let userInteraction = UserInteractionService()
    let operation = OperationService()
}

protocol DriverAccessible {
}
extension DriverAccessible {
    var driver: Driver {
        return Driver.theDriver
    }
}










