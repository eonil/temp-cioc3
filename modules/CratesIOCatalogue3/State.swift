//
//  State.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import EonilToolbox

struct State {
    var database = DatabaseState()
    var navigation = NavigationState()
}

/// View-level state database.
/// Some data can be thought as a local-cache of remote data obtained by API call.
/// Some data can be stored in local storage such as SQLite database if needed.
struct DatabaseState {
    var crates = [CrateID: CrateState]()
}
struct NavigationState {
    var mode: ModeID = .Browse
    var home = HomeState()
    var search: SearchNavigationState?
    var detailStack = [CrateID]()

//    mutating func pushCrateDetail(crateID: CrateID) {
//
//    }
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
    var serversideID: Int32
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
























