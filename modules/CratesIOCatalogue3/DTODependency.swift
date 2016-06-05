//
//  Dependency.swift
//  CratesIOViewer
//
//  Created by Hoon H. on 11/21/14.
//
//

///	https://github.com/rust-lang/crates.io/blob/master/src/dependency.rs
public struct DTODependency {
    public var	id					:	Int32
    public var	version_id			:	Int32
    public var	crate_id			:	String
    public var	req					:	String
    public var	optional			:	Bool
    public var	default_features	:	Bool
    public var	features			:	String
    public var	target				:	String?
    public var	kind				:	Kind

    public enum Kind: String {
        case Normal	=	"normal"
        case Build	=	"build"
        case Dev	=	"dev"
    }
}








