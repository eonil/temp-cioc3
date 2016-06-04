//
//  APIService.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

/// Provides access to remote API server.
///
/// API service does not keep or manage any local cache
/// and always perform full query to the server.
///
final class DatabaseService {
    func queryPopularCrateIDs() -> Task<[CrateID]> {

    }
    func queryCrateSummaryFor(crateID: CrateID) -> Task<CrateSummaryState> {

    }
    func queryCrateDetailFor(crateID: CrateID) -> Task<CrateDetailState> {

    }
}
