//
//  SwiftExtensions.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

extension Dictionary {
    /// - Parameter key: Key to value to mutate. If this dictionary does not have the key
    ///                     program crashes.
    mutating func performTransactionFor(key: Key, @noescape transaction: (inout Value) -> ()) {
        guard let v = self[key] else { fatalError("No value for the key `\(key)`.") }
        var v1 = v
        transaction(&v1)
        self[key] = v1
    }
    mutating func performTransactionOptionallyFor(key: Key, @noescape transaction: (inout Value?) -> ()) {
        transaction(&self[key])
    }
}

extension Optional {
    func applyOptionally(@noescape f: Wrapped -> ()) {
        guard let wrapped = self else { return }
        f(wrapped)
    }
}