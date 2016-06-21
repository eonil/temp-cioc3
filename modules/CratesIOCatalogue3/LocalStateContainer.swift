//
//  InequalityContainer.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/21.
//  Copyright © 2016 Eonil. All rights reserved.
//

//protocol LocalStateContainerType {
//    associatedtype Content
//    var content: Content { get }
//}
struct LocalStateContainer<T: Equatable> {
    private(set) var content: T
    init(_ content: T) {
        self.content = content
    }
    mutating func set(newContent: T, @noescape onUpdate: ()->() = {}) {
        guard content != newContent else { return }
        content = newContent
        onUpdate()
    }
}


