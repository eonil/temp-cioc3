//
//  BoltsExtensions.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

import BoltsSwift

extension Task {
    func branch(@noescape f: Task -> ()) -> Task {
        f(self)
        return self
    }
}