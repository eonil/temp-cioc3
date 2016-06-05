//
//  JSONParsing.swift
//  Precompilation
//
//  Created by Hoon H. on 2016/06/02.
//  Copyright © 2016 Eonil. All rights reserved.
//

import EonilJSON

public enum JSONParsingError: ErrorType {
    case MissingNode
    case UnexpectedTypeValue
}

public protocol JSONParsingInitialzable {
    init(json: JSON.Object) throws
}

public extension JSONParsingInitialzable {
    init(json: JSON.Object?) throws {
        guard let json = json else { throw JSONParsingError.MissingNode }
        self = try Self(json: json)
    }
}








////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension DTODependency: JSONParsingInitialzable {
    public init(json: JSON.Object) throws {
        id					=	try nilTrap(json["id"]?.number?.integer?.int32)
        version_id			=	try nilTrap(json["version_id"]?.number?.integer?.int32)
        crate_id			=	try nilTrap(json["crate_id"]?.string)
        req					=	try nilTrap(json["req"]?.string)
        optional			=	try nilTrap(json["optional"]?.boolean)
        default_features	=	try nilTrap(json["default_features"]?.boolean)
        features			=	try nilTrap(json["features"]?.string)
        target				=	json["target"]?.string
        kind				=	try nilTrap(json["kind"]?.toDependencyKind())
    }
}

extension DTOCrate: JSONParsingInitialzable {
    public init(json: JSON.Object) throws {
        id				=	try nilTrap(json["id"]?.string)
        name			=	try nilTrap(json["name"]?.string)
        updated_at		=	try nilTrap(json["updated_at"]?.string)
        versions		=	(try? json["versions"]?.toInt32Array()) ?? nil // Should become `nil` on parsing failure.
        created_at		=	try nilTrap(json["created_at"]?.string)
        downloads		=	try nilTrap(json["downloads"]?.number?.integer?.int32)
        max_version		=	try nilTrap(json["max_version"]?.string)
        description		=	json["description"]?.string
        homepage		=	json["homepage"]?.string
        documentation	=	json["documentation"]?.string
        keywords		=	(try? json["keywords"]?.toStringArray() ?? []) ?? []
        license			=	json["license"]?.string
        repository		=	json["repository"]?.string
        links			=	try nilTrap(json["links"]?.toCreateLinks())

        //	Post-procesing wweird newlines.
        if let d1 = description {
            description		=	d1.stringByReplacingOccurrencesOfString("\n", withString: " ", options: [], range: nil)
        }
    }
}

extension DTOCrateLinks: JSONParsingInitialzable {
    public init(json: JSON.Object) throws {
        version_downloads	=	try nilTrap(json["version_downloads"]?.string)
        versions			=	json["versions"]?.string
        owners				=	json["owners"]?.string
    }
}

extension DTOKeyword: JSONParsingInitialzable {
    public init(json: JSON.Object) throws {
        id			=	try nilTrap(json["id"]?.string)
        keyword		=	try nilTrap(json["keyword"]?.string)
        created_at	=	try nilTrap(json["created_at"]?.string)
        crates_cnt	=	try nilTrap(json["crates_cnt"]?.number?.integer?.int32)
    }
}

extension DTOUser: JSONParsingInitialzable {
    public init(json: JSON.Object) throws {
        id		=	try nilTrap(json["id"]?.number?.integer?.int32)
        login	=	try nilTrap(json["login"]?.string)
        email	=	json["email"]?.string
        name	=	json["name"]?.string
        avatar	=	json["avatar"]?.string
    }
}

extension DTOVersion: JSONParsingInitialzable {
    public init(json: JSON.Object) throws {
        id			=	try nilTrap(json["id"]?.number?.integer?.int32)
//		krate		=	try nilTrap(json["krate"]?.string)
        num			=	try nilTrap(json["num"]?.string)
//		dl_path		=	try nilTrap(json["dl_path"]?.string)
        updated_at	=	try nilTrap(json["updated_at"]?.string)
        created_at	=	try nilTrap(json["created_at"]?.string)
        downloads	=	try nilTrap(json["downloads"]?.number?.integer?.int32)
        features	=	try nilTrap(json["features"]?.toDictionaryOfStringToStringArray())
        yanked		=	try nilTrap(json["yanked"]?.boolean)
    }
}

extension DTOSummary: JSONParsingInitialzable {
    public init(json: JSON.Object) throws {
        num_downloads	=	try nilTrap(json["num_downloads"]?.number?.integer)
        num_crates		=	try nilTrap(json["num_crates"]?.number?.integer)
        new_crates		=	try nilTrap(json["new_crates"]?.toCrateArray())
        most_downloaded	=	try nilTrap(json["most_downloaded"]?.toCrateArray())
        just_updated	=	try nilTrap(json["just_updated"]?.toCrateArray())
    }
}







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

internal func nilTrap<T>(optionalValue: T?) throws -> T {
    guard let value = optionalValue else { throw JSONParsingError.MissingNode }
    return value
}



















