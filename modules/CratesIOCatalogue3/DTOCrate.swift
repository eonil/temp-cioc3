//
//  Crate.swift
//  CratesIOViewer
//
//  Created by Hoon H. on 11/21/14.
//
//

public struct DTOCrate {
    public var	id				:	String
    public var	name			:	String
    public var	updated_at		:	String
    public var	versions		:	[Int32]?
    public var	created_at		:	String
    public var	downloads		:	Int32
    public var	max_version		:	String
    public var	description		:	String?
    public var	homepage		:	String?
    public var	documentation	:	String?
    public var	keywords		:	[String]
    public var	license			:	String?
    public var	repository		:	String?
    public var	links			:	DTOCrateLinks
}

public struct DTOCrateLinks {
    public var	version_downloads	:	String
    public var	versions			:	String?
    public var	owners				:	String?
}































