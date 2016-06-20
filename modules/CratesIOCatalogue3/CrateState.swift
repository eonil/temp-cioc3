//
//  CrateState.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/17.
//  Copyright © 2016 Eonil. All rights reserved.
//

struct CrateState: VersioningState {
    private(set) var version = Version()
    /// Only server manages crate key, so server-side ID
    /// always exists.
    private(set) var serversideID: String
    /// Can be missing if the Crate information is retrieved from dependency query or etc..
    private(set) var basics: CrateStateBasics?
    var extras = CrateStateExtras()

    init(serversideID: String) {
        self.serversideID = serversideID
    }
    mutating func setExtrasTransferrings() {
        extras.setTransferring()
        version.revise()
    }
    mutating func update(dto: DTOCrate) {
        basics = CrateStateBasics(dto: dto)
        version.revise()
    }
    mutating func update(dto: [(CrateID, DTODependency)]) {
        extras.update(dto)
        version.revise()
    }
    mutating func update(dto: [DTOAuthor]) {
        extras.update(dto)
        version.revise()
    }
    mutating func update(dto: [DTOVersion]) {
        extras.update(dto)
        version.revise()
    }

//    func updated(dto: DTOCrate) -> CrateState {
//        var copy = self
//        copy.update(dto)
//        return copy
//    }
}
struct CrateDependencyState {
    var name: String
}






















