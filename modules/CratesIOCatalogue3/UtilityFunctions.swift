//
//  UtilityFunctions.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

@noreturn
func MARK_unimplemented() {
    fatalError("This feature has not been implemented.")
}

func debugLog<T>(value: T) {
    assert({
        print("\(value)")
        return true
    }())
}

/// `fatalError(message)`, but report first before crash.
@noreturn
func fatalErrorWithReporting(message: String) {
    MARK_unimplemented()
//    fatalError(message)
}