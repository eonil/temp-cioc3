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
struct DatabaseState: VersioningState {
    private(set) var version = Version()
    private(set) var crates = [CrateID: CrateState]()
    private var crateServersideIDMapping = [String: CrateID]()
    mutating func setCrateExtrasTransferring(crateID: CrateID) {
        crates[crateID]?.setExtrasTransferrings()
        version.revise()
    }
    private mutating func pushCrate(serversideID serversideID: String) -> CrateID {
        if let oldCrateID = crateServersideIDMapping[serversideID] {
            return oldCrateID
        }
        else {
            let newCrateID = CrateID()
            crateServersideIDMapping[serversideID] = newCrateID
            crates[newCrateID] = CrateState(serversideID: serversideID)
            version.revise()
            return newCrateID
        }
    }
    private mutating func appendOrUpdateCrate(dto: DTODependency) -> CrateID {
        let crateID = pushCrate(serversideID: dto.crate_id)
        version.revise()
        return crateID
    }
    mutating func appendOrUpdateCrate(dto: DTOCrate) -> CrateID {
        let crateID = pushCrate(serversideID: dto.id)
        crates[crateID]?.update(dto)
        version.revise()
        return crateID
    }
    mutating func clearExtrasOf(crateID: CrateID) {
        crates[crateID]?.extras.authors.reset()
        crates[crateID]?.extras.dependencies.reset()
        crates[crateID]?.extras.versions.reset()
        version.revise()
    }
    mutating func update(crateID crateID: CrateID, dto: [DTOAuthor]) {
        crates[crateID]?.update(dto)
        version.revise()
    }
    mutating func update(crateID crateID: CrateID, dto: [DTODependency]) {
        let dto1 = dto.map({ dtoDependency in (pushCrate(serversideID: dtoDependency.crate_id), dtoDependency) })
        crates[crateID]?.update(dto1)
        version.revise()
    }
    mutating func update(crateID crateID: CrateID, dto: [DTOVersion]) {
        crates[crateID]?.update(dto)
        version.revise()
    }
}

/// To change navigation state,
/// 1. Copy current state
/// 2. modify it using mutator methods.
/// 3. Dispatch modified state to driver.
struct NavigationState {
    private(set) var version = Version()
    private(set) var mode: ModeID = .Browse
    private(set) var home = HomeState()
    private(set) var search = SearchNavigationState()
    private(set) var crateInspectorStack = [CrateInspectionState]()

    init() {
    }
    mutating func setSearchResult(newResult: SearchResultState) {
        search.result = newResult
    }
    mutating func resetCrateInspectorStack(newCrateInspectorStack: [CrateInspectionState]) {
        crateInspectorStack = newCrateInspectorStack
        version.revise()
    }
    mutating func setMode(newMode: DatasheetModeID, ofCrateInspectorAtIndex index: Int) {
        crateInspectorStack[index].datasheetMode = newMode
        version.revise()
    }
    mutating func pushCrateInspector(crateID: CrateID) {
        mode = .Browse
        crateInspectorStack.append(CrateInspectionState(crateID: crateID, datasheetMode: .links))
        version.revise()
    }
    mutating func popTopCrateInspector() {
        mode = .Browse
        crateInspectorStack.removeLast()
        version.revise()
    }
}

enum ModeID {
    case Browse
    case Search
}

struct CrateInspectionState {
    var crateID: CrateID
    var datasheetMode: DatasheetModeID?
}
enum DatasheetModeID {
    case links
    case dependencies
    case versions
}
extension DatasheetModeID {
    static let all: [DatasheetModeID] = [.links, .dependencies, .versions]
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
struct SummaryState {

}
struct SearchNavigationState {
    var expression: String?
    var result = SearchResultState()
}
struct SearchResultState {
    var transmission = Transmissive<[CrateID]>()
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
























