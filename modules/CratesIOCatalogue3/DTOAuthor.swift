//
//  Author.swift
//  CratesIOViewer
//
//  Created by Hoon H. on 11/23/14.
//
//

public enum DTOAuthor {
    case User(DTOUser)
    case Name(String)
}
extension DTOAuthor {
	public var name: String {
		get {
			switch self {
			case .User(let s):
				return	s.name ?? s.login
				
			case .Name(let s):
				return	s
			}
		}
	}
}






