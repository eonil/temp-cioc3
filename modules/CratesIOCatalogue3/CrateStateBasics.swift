//
//  CrateStateBasics.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

struct CrateStateBasics {
    var	name: String
    var	version: String
    var	description: String?

    var license: String?
    var downloads: Int32

    var homepage: String?
    var documentation: String?
    var repository: String?
}
extension CrateStateBasics {
    init(dto: DTOCrate) {
        name = dto.name
        version = dto.max_version
        description = dto.description
        license = dto.license
        downloads = dto.downloads
        homepage = dto.homepage
        documentation = dto.documentation
        repository = dto.repository
    }
}
