//
//  State.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

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
    var screen: ScreenState = .Home
    var home = HomeState()
    var search: SearchNavigationState?
    var detailStack = [CrateID]()
}
enum ScreenState {
    case Home
    /// - Parameter stack:
    ///     Stacked details screens.
    case Search
    case CrateDetail(stack: [CrateID])
}
struct HomeState {
    var popularItems = [CrateID]()
    var newItems = [CrateID]()
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




struct CrateID: Hashable {
    var hashValue: Int {
        return
    }
}
func ==(a: CrateID, b: CrateID) -> Bool {
    return
}
struct CrateSummaryState {
}
struct CrateDetailState {
}
















