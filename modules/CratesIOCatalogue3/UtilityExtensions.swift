//
//  UtilityExtensions.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/05.
//  Copyright © 2016 Eonil. All rights reserved.
//

extension Array {
    mutating func popFirst() -> Element? {
        if count == 0 { return nil }
        return removeFirst()
    }
}