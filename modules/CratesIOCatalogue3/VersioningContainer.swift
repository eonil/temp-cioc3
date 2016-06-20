//
//  VersioningContainer.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/20.
//  Copyright © 2016 Eonil. All rights reserved.
//

protocol VersioningState {
    var version: Version { get }
}

struct VersioningContainer<T>: VersioningState {
    var version: Version
    var content: T

    init(version: Version, content: T) {
        self.version = version
        self.content = content
    }
}


























