//
//  Summary.swift
//  Precompilation
//
//  Created by Hoon H. on 12/1/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

///	https://github.com/rust-lang/crates.io/blob/master/src/krate.rs#L557
public struct DTOSummary {
    public var	num_downloads:Int64
    public var	num_crates:Int64
    public var	new_crates:[DTOCrate]
    public var	most_downloaded:[DTOCrate]
    public var	just_updated:[DTOCrate]
}

	