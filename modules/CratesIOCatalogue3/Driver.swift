//
//  Driver.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

final class Driver {
    private static let theDriver = Driver()
    private(set) var state = State()
    func dispatch(command: DriverCommand) -> Task<()> {

    }
}

protocol DriverAccessible {
}
extension DriverAccessible {
    var driver: Driver {
        return Driver.theDriver
    }
}