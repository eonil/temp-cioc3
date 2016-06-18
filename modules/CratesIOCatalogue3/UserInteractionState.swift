//
//  UserInteractionState.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import EonilToolbox

struct UserInteractionState {
    private(set) var version = Version()
    var database = DatabaseState() {
        didSet { version.revise() }
    }
    var navigation = NavigationState() {
        didSet { version.revise() }
    }
}

extension UserInteractionState {
    mutating func reloadHome(dtoSummary: DTOSummary) {
        navigation.home.justUpdatedItems = dtoSummary.just_updated.map { database.appendOrUpdateCrate($0) }
        navigation.home.newItems = dtoSummary.new_crates.map { database.appendOrUpdateCrate($0) }
        navigation.home.mostDownloadedItems = dtoSummary.most_downloaded.map { database.appendOrUpdateCrate($0) }
    }
}

/// View-level state database.
/// Some data can be thought as a local-cache of remote data obtained by API call.
/// Some data can be stored in local storage such as SQLite database if needed.
struct DatabaseState {
    private(set) var crates = [CrateID: CrateState]()
    private var crateServersideIDMapping = [String: CrateID]()
    mutating func setCrateExtrasTransferring(crateID: CrateID) {
        crates[crateID]?.setExtrasTransferrings()
    }
    mutating func appendOrUpdateCrate(dto: DTOCrate) -> CrateID {
        if let oldCrateID = crateServersideIDMapping[dto.id] {
            crates[oldCrateID]?.update(dto)
            return oldCrateID
        }
        else {
            let newCrateID = CrateID()
            let newCrateStateBasics = CrateStateBasics(dto: dto)
            crateServersideIDMapping[dto.id] = newCrateID
            crates[newCrateID] = CrateState(serversideID: dto.id, basics: newCrateStateBasics)
            return newCrateID
        }
    }
    mutating func update(crateID crateID: CrateID, dto: [DTOVersion]) {
        crates[crateID]?.update(dto)
    }
}

/// To change navigation state,
/// 1. Copy current state
/// 2. modify it using mutator methods.
/// 3. Dispatch modified state to driver.
struct NavigationState {
    private(set) var mode: ModeID = .Browse
    private(set) var home = HomeState()
    private(set) var search: SearchNavigationState?
    private(set) var detailStack = [CrateID]()

    init() {
    }
    mutating func resetDetailStack(newDetailStack: [CrateID]) {
        detailStack = newDetailStack
    }
    mutating func pushCrateDetail(crateID: CrateID) {
        mode = .Browse
        detailStack.append(crateID)
    }
    mutating func popTopCrateDetail() {
        mode = .Browse
        detailStack.removeLast()
    }
}
enum ModeID {
    case Browse
    case Search
}
struct HomeState {
    private(set) var version = Version()
    var newItems = [CrateID]() {
        didSet { version.revise() }
    }
    var mostDownloadedItems = [CrateID]() {
        didSet { version.revise() }
    }
    var justUpdatedItems = [CrateID]() {
        didSet { version.revise() }
    }
}
struct SearchNavigationState {
    var expression: String?
    var result: SearchResultState
}
struct SearchResultState {
    var items: [CrateID]
}
struct DetailNavigationState {
    var crateID: CrateID
}







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct CrateID: Hashable {
    private let oid = ObjectAddressID()
    var hashValue: Int {
        return oid.hashValue
    }
}
func ==(a: CrateID, b: CrateID) -> Bool {
    return a.oid == b.oid
}
























