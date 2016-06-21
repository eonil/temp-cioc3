//
//  PriorityContainer.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/21.
//  Copyright © 2016 Eonil. All rights reserved.
//

struct PriorityContainer<Priority: Comparable, Content> {
    private(set) var priority: Priority
    private(set) var content: Content
    mutating func setIfAppropriate(newContent: Content, at newPriority: Priority, @noescape onUpdate: () -> () = {}) {
        guard newPriority >= priority else { return }
        content = newContent
        onUpdate()
    }
}
