//
//  RecordDeletedEntity.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Records the name of an entity right before it is permanently deleted, so it can still be
/// displayed afterward wherever its id remains referenced.
final class RecordDeletedEntity {

    private let repository: DeletedEntityProviding

    /// - Parameter repository: The data contract for deleted-entity persistence.
    init(repository: DeletedEntityProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - id: The identifier the entity had before deletion.
    ///   - name: The entity's name at the time of deletion.
    ///   - kind: Whether this was an account or an institution.
    func execute(id: UUID, name: String, kind: DeletedEntityKind) async throws {
        try await repository.save(DeletedEntity(id: id, name: name, kind: kind))
    }
}
