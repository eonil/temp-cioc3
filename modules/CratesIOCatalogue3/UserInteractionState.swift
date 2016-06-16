//
//  UserInteractionState.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import EonilToolbox

struct UserInteractionState {
    var database = DatabaseState()
    var navigation = NavigationState()
}

extension UserInteractionState {
    mutating func reloadHome(dtoSummary: DTOSummary) {
        navigation.home.justUpdatedItems = dtoSummary.just_updated.map { database.appendOrUpdateCrate($0) }
        navigation.home.newItems = dtoSummary.new_crates.map { database.appendOrUpdateCrate($0) }
        navigation.home.popularItems = dtoSummary.most_downloaded.map { database.appendOrUpdateCrate($0) }
    }
}

/// View-level state database.
/// Some data can be thought as a local-cache of remote data obtained by API call.
/// Some data can be stored in local storage such as SQLite database if needed.
struct DatabaseState {
    private(set) var crates = [CrateID: CrateState]()
    private var crateServersideIDMapping = [String: CrateID]()
    mutating func appendOrUpdateCrate(dto: DTOCrate) -> CrateID {
        if let oldCrateID = crateServersideIDMapping[dto.id] {
            return oldCrateID
        }
        else {
            let newCrateID = CrateID()
            crateServersideIDMapping[dto.id] = newCrateID
            crates[newCrateID] = CrateState(serversideID: dto.id, summary: nil, detail: nil)
            return newCrateID
        }
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
    var popularItems = [CrateID]() {
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

struct CrateState {
    /// Only server manages crate key, so server-side ID
    /// always exists.
    var serversideID: String
    var summary: CrateSummaryState?
    var detail: CrateDetailState?
}
struct CrateSummaryState {
    var	name			:	String
    var	version         :	String
    var	description		:	String?
}
struct CrateDetailState {
    var authors: [String]
    var license: String?
    var downloads: Int32

    var homepage: String?
    var documentation: String?
    var repository: String?

    var dependencies: [(id: CrateID, name: String)] = []
    var versions: [(name: String, date: NSDate)] = []
}
extension CrateDetailState {
    mutating func reconfigure(dto: DTOCrate) {
        license = dto.license
        downloads = dto.downloads
        homepage = dto.homepage
        documentation = dto.documentation
        repository = dto.repository
    }
    mutating func reconfigure(dto: [DTOAuthor]) {
        authors = dto.map { $0.name }
    }
    mutating func reconfigure(dto: [DTOVersion]) {
    }
}

struct CrateDependencyState {
    var name: String
    
}
























