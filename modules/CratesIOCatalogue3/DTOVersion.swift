//
//  Version.swift
//  CratesIOViewer
//
//  Created by Hoon H. on 11/21/14.
//
//

///	https://github.com/rust-lang/crates.io/blob/master/src/version.rs
public struct DTOVersion {
    public var	id				:	Int32
//    public var	krate			:	String		//	I don't know why but this is not being passed though it is noted on the struct.
    public var	num				:	String
//    public var	dl_path			:	String		//	Also missing.
    public var	updated_at		:	String
    public var	created_at		:	String
    public var	downloads		:	Int32
    public var	features		:	[String:[String]]
    public var	yanked			:	Bool
//    public var	links			:	VersionLinks
}
//struct VersionLinks {
//    var	dependencies		:	String
//    var	version_downloads	:	String
//    var	authors				:	String
//}




















extension DTOVersion {
	
}






























