//
//  Data.swift
//  CratesIOViewer
//
//  Created by Hoon H. on 11/22/14.
//
//

import Foundation

///	Provides complexly chained operations.
public struct Data {
	
	public struct Crate {
		public struct Full {
			
			public var	crateBasics					:	DTOCrate
			public var	currentVersionDependencies	:	[DTODependency]
			public var	currentVersionAuthors		:	[DTOAuthor]
			public var	allVersions					:	[DTOVersion]
			
			





			public static func fetch(id crate_id:String, callback:Status<Full>->()) -> CancellableTask {
				var	all_cancels	=	[] as [CancellableTask]
				let	cancel1		=	APIService.Crate.show(crate_id) { (s:Status<APIService.Crate.showResult>)->() in
					
					switch s {
					case .Error(let s):
						callback(Status<Data.Crate.Full>.Error(s))
						return
						
					case .Cancel:
						callback(Status<Data.Crate.Full>.Cancel)
						return
						
					case .Ready(let s):
						let	s1	=	s()
						let	c1	=	s1.crate
						let	v2	=	{ ()->DTOVersion? in
							for v1 in s1.versions {
								if v1.num == c1.max_version {
									return	v1
								}
							}
							return	nil
						}()!
						
						let	cancel2	=	DTOVersion.dependencies(crate_id: c1.id, version: v2.num) { (s2:Status<[DTODependency]>)->() in
							switch s2 {
							case .Error(let s):
								callback(Status<Data.Crate.Full>.Error(s))
								return
								
							case .Cancel:
								callback(Status<Data.Crate.Full>.Cancel)
								return
								
							case .Ready(let data2):
								
								let	cancel3	=	DTOVersion.authors(crate_id: c1.id, version: v2.num) { (s3:Status<[DTOAuthor]>)->() in
									switch s3 {
									case .Error(let s):
										callback(Status<Data.Crate.Full>.Error(s))
										return
										
									case .Cancel:
										callback(Status<Data.Crate.Full>.Cancel)
										return
									
									case .Ready(let data3):
										let	bass	=	c1
										let	deps	=	data2()
										let	aths	=	data3()
										let	vers	=	s1.versions
										let	f1		=	Full(crateBasics: bass, currentVersionDependencies: deps, currentVersionAuthors:aths, allVersions: vers)
										callback(Status<Data.Crate.Full>.Ready({f1}))
										return
									}
								}
								all_cancels.append(cancel3)
							}
						}
						all_cancels.append(cancel2)
					}
				}
				all_cancels.append(cancel1)
				
				return	CancellableTask {
					for c in all_cancels {
						c.cancel()
					}
				}
			}
		}
	}
}