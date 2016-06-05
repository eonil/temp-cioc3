//
//  JSONParsingExtensions.swift
//  Precompilation
//
//  Created by Hoon H. on 2016/06/02.
//  Copyright © 2016 Eonil. All rights reserved.
//

import EonilJSON

extension Int64 {
    var int32:Int32? {
        get {
            if IntMax(self) <= IntMax(Int32.max) && IntMax(self) >= IntMax(Int32.min) {
                return Int32(self)
            }
            return nil
        }
    }
}

extension JSON.Value {
    func toInt32Array() throws -> [Int32] {
        if let j2 = self.array {
            var	ss = [] as [Int32]
            for j3 in j2 {
                if let s2 = j3.number?.integer?.int32 {
                    ss.append(s2)
                } else {
                    throw JSONParsingError.UnexpectedTypeValue
                }
            }
            return ss
        }
        throw JSONParsingError.UnexpectedTypeValue
    }
    func toStringArray() throws -> [Swift.String] {
        guard let j2 = array else { throw JSONParsingError.UnexpectedTypeValue }
        var	ss = [] as [Swift.String]
        for j3 in j2 {
            guard let s2 = j3.string else { throw JSONParsingError.UnexpectedTypeValue }
            ss.append(s2)
        }
        return ss
    }
}

extension JSON.Value {
    func toCrate() throws -> DTOCrate {
        self.object
        return try DTOCrate(json: self.object)
    }
    func toCrateArray() throws -> [DTOCrate] {
        guard let j2 = array else { throw JSONParsingError.UnexpectedTypeValue }
        return try j2.map({ try $0.toCrate() })
    }
    func toCreateLinks() throws -> DTOCrateLinks {
        if let j2 = self.object {
            return try DTOCrateLinks(json: j2)
        }
        throw JSONParsingError.UnexpectedTypeValue
    }
}

extension JSON.Value {
    func toAuthor() throws -> DTOAuthor {
        if let o1 = try? DTOUser(json: object) {
            return DTOAuthor.User(o1)
        }
        if let s1 = string {
            return DTOAuthor.Name(s1)
        }
        throw JSONParsingError.UnexpectedTypeValue
    }
    func toAuthorArray() throws -> [DTOAuthor] {
        if object?["users"] == nil && object?["meta"]?.object?["names"] == nil {
            throw JSONParsingError.UnexpectedTypeValue
        }

        var	as1	= [] as [DTOAuthor]

        if let us1 = try object?["users"]?.toUserArray() {
            let	as2	= us1.map({DTOAuthor.User($0)})
            as1 += as2
        }
        
        if let ss1 = try object?["meta"]?.object?["names"]?.toStringArray() {
            let	as2	= ss1.map({DTOAuthor.Name($0)})
            as1 += as2
        }
        
        return as1
    }
}

extension JSON.Value {
    func toDependencyKind() throws -> DTODependency.Kind {
        if let s = string {
            if let k = DTODependency.Kind(rawValue: s) {
                return k
            }
        }
        throw JSONParsingError.UnexpectedTypeValue
    }
    func toDependency() throws -> DTODependency {
        return try DTODependency(json: object)
    }
    func toDependencyArray() throws -> [DTODependency] {
        guard let array = array else { throw JSONParsingError.UnexpectedTypeValue }
        return try array.map({ try $0.toDependency() })
    }
}

extension JSON.Value {
    func toKeyword() throws -> DTOKeyword {
        return try DTOKeyword(json: object)
    }
    func toKeywordArray() throws -> [DTOKeyword] {
        guard let array = array else { throw JSONParsingError.UnexpectedTypeValue }
        return try array.map({ try $0.toKeyword() })
    }
}

extension JSON.Value {
    func toDictionaryOfStringToStringArray() throws -> [Swift.String:[Swift.String]] {
        guard let object = object else { throw JSONParsingError.UnexpectedTypeValue }
        var	d1 = [:] as [Swift.String:[Swift.String]]
        for (k,v) in object {
            guard let array = v.array else { throw JSONParsingError.UnexpectedTypeValue }
            d1[k] = try array.flatMap({
                guard $0.string != nil else { throw JSONParsingError.UnexpectedTypeValue }
                return $0.string
            })
        }
        return d1
    }
    func toVersion() throws -> DTOVersion {
        return try DTOVersion(json: object)
    }
    func toVersionArray() throws -> [DTOVersion] {
        guard let array = array else { throw JSONParsingError.UnexpectedTypeValue }
        return try array.map({ try $0.toVersion() })
    }
}

extension JSON.Value {
    func toUser() throws -> DTOUser {
        return try DTOUser(json: object)
    }
    func toUserArray() throws -> [DTOUser] {
        guard let array = array else { throw JSONParsingError.UnexpectedTypeValue }
        return try array.map({ try DTOUser(json: $0.object) })
    }
}

extension JSON.Value {
    func toSummary() throws -> DTOSummary {
        guard let object = object else { throw JSONParsingError.UnexpectedTypeValue }
        return try DTOSummary(json: object)
    }
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private extension Array {
    private func checkCount(count: Int) throws -> Array<Element> {
        guard self.count == count else { throw JSONParsingError.UnexpectedTypeValue }
        return self
    }
}



