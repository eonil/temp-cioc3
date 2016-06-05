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
    var crateSummaries = [CrateID: CrateSummaryState]()
    var crateDetails = [CrateID: CrateDetailState]()
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
    var newItems = [CrateID]()
    var popularItems = [CrateID]()
    var justUpdatedItems = [CrateID]()
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

struct CrateSummaryState {
}
struct CrateDetailState {
}
















