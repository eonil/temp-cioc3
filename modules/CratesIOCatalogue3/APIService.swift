//
//  APIService.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import BoltsSwift
import EonilJSON

enum APIError: ErrorType {
    case CannotMakeRequestURL
    case UnexpectedResponseContent
}

/// Provides access to remote API server.
///
/// API service does not keep or manage any local cache
/// and always perform full query to the server.
///
struct APIService {
    private init() {
    }

    struct Home {
        /// Gets summary for home screen.
        static func summary() -> Task<DTOSummary> {
            assertNonMainThread()
            let u = NSURLComponents()
            u.scheme = "https"
            u.host = "crates.io"
            u.path = "/summary"		// This is the only exception that does not use `/api/v1` prefix. I don't know why. Ask them.
            u.port = 443
            guard let u1 = u.URL else { return Task(error: APIError.CannotMakeRequestURL) }
            return HTTPService.getJSON(u1).continueOnSuccessWith(continuation: { (j: JSON.Value) throws -> DTOSummary in
                return try j.toSummary()
            })
        }
    }

    struct Search {
        enum Sort: String {
            case Alpha		=	"alpha"
            case Downloads	=	"downloads"
        }
        /// - Parameter page:
        ///     0-based page index.
        static func index(query: String?, page: Int, per_page: Int, sort: Sort) -> Task<[DTOCrate]> {
            assertNonMainThread()
            assert(query == nil || query != "", "Query text must be `nil` or non-zero length string.")
            let	ps = [
                "page"		:	(page+1).description,
                "per_page"	:	per_page.description,
                "sort"		:	sort.rawValue,
                "q"         :   query,
                ]

            let u = NSURLComponents()
            u.scheme = "https"
            u.host = "crates.io"
            u.path = "/api/v1/crates"
            u.queryItems = ps.map({ NSURLQueryItem(name: $0.0, value: $0.1) })
            u.port = 443
            guard let u1 = u.URL else { return Task(error: APIError.CannotMakeRequestURL) }
            return HTTPService.getJSON(u1).continueOnSuccessWith(continuation: { (j: JSON.Value) throws -> [DTOCrate] in
                guard let a = try j.object?["crates"]?.toCrateArray() else { throw APIError.UnexpectedResponseContent }
                return a
            })
        }
    }

    struct Crate {
        typealias ShowResult = (crate:DTOCrate, versions:[DTOVersion], keywords:[DTOKeyword])
        static func show(id: String) -> Task<ShowResult> {
            assertNonMainThread()
            let u = NSURLComponents()
            u.scheme = "https"
            u.host = "crates.io"
            u.path = "/api/v1/crates/\(id)"
            u.port = 443
            guard let u1 = u.URL else { return Task(error: APIError.CannotMakeRequestURL) }
            return HTTPService.getJSON(u1).continueOnSuccessWith(continuation: { (j: JSON.Value) throws -> ShowResult in
                guard let a = try j.object?["crate"]?.toCrate() else { throw APIError.UnexpectedResponseContent }
                guard let b = try j.object?["versions"]?.toVersionArray() else { throw APIError.UnexpectedResponseContent }
                guard let c = try j.object?["keywords"]?.toKeywordArray() else { throw APIError.UnexpectedResponseContent }
                return (a, b, c)
            })
        }

        /// - Parameter version:
        ///     Semantic versioning expression. (ex: `0.0.1`)
        static func dependencies(crate_id:String, version:String) -> Task<[DTODependency]> {
            assertNonMainThread()
            let u = NSURLComponents()
            u.scheme = "https"
            u.host = "crates.io"
            u.path = "/api/v1/crates/\(crate_id)/\(version)/dependencies"
            u.port = 443
            guard let u1 = u.URL else { return Task(error: APIError.CannotMakeRequestURL) }
            return HTTPService.getJSON(u1).continueOnSuccessWith(continuation: { (j: JSON.Value) throws -> [DTODependency] in
                guard let a = try j.object?["dependencies"]?.toDependencyArray() else { throw APIError.UnexpectedResponseContent }
                return a
            })
        }

        /// - Parameter version:
        ///     Semantic versioning expression. (ex: `0.0.1`)
        static func authors(crate_id:String, version:String) -> Task<[DTOAuthor]> {
            assertNonMainThread()
            let u = NSURLComponents()
            u.scheme = "https"
            u.host = "crates.io"
            u.path = "/api/v1/crates/\(crate_id)/\(version)/authors"
            u.port = 443
            guard let u1 = u.URL else { return Task(error: APIError.CannotMakeRequestURL) }
            return HTTPService.getJSON(u1).continueOnSuccessWith(continuation: { (j: JSON.Value) throws -> [DTOAuthor] in
                let a = try j.toAuthorArray() 
                return a
            })
        }
    }

//    struct Keyword {
//        static func index(page:Int, per_page:Int) -> Task<[DTOKeyword]> {
//            MARK_unimplemented()
//        }
//    }
//    struct Version {
//        static func index() -> Task<[DTOVersion]> {
//            MARK_unimplemented()
//        }
//    }
}
