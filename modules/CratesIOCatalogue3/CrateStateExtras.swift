//
//  CrateStateExtras.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

struct CrateStateExtras {
    private(set) var authors = Transmissive<[String]>()
    private(set) var dependencies = Transmissive<[(id: CrateID, name: String)]>()
    private(set) var versions = Transmissive<[(name: String, date: String)]>()
}
extension CrateStateExtras {
    var isReady: Bool {
        return authors.isReady && dependencies.isReady && versions.isReady
    }
    func needsReloadingAny() -> Bool {
        let timeout = NSTimeInterval(3)
        return authors.needsReloading(timeout) || dependencies.needsReloading(timeout) || versions.needsReloading(timeout)
    }
    //    func isTransferringAny() -> Bool {
    //        return authors.isTransferring || dependencies.isTransferring || versions.isTransferring
    //    }
    mutating func setTransferring() {
        authors.setTransferring()
        dependencies.setTransferring()
        versions.setTransferring()
    }
    mutating func update(dto: [DTOAuthor]) {
        authors.setDownloaded(dto.map { $0.name })
    }
    /// - Parameter dto: Pair of ID and DTO.
    ///                     The ID must be already inserted into the database.
    mutating func update(dto: [(CrateID, DTODependency)]) {
        dependencies.setDownloaded(dto.map { id, dependency in (id, dependency.crate_id) })
    }
    mutating func update(dto: [DTOVersion]) {
        versions.setDownloaded(dto.map { ($0.num, $0.created_at) })
    }
}

