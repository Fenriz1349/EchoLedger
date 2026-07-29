//
//  GetDeletedEntity.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Resolves the display name of a previously deleted account or institution, for display
/// fallback wherever a live lookup by id no longer resolves to anything.
final class GetDeletedEntity {

    private let repository: DeletedEntityProviding

    /// - Parameter repository: The data contract for deleted-entity persistence.
    init(repository: DeletedEntityProviding) {
        self.repository = repository
    }

    /// - Parameter id: The identifier the entity had before deletion.
    /// - Returns: The matching trace, or `nil` if this id was never deleted.
    func execute(id: UUID) async throws -> DeletedEntity? {
        try await repository.fetch(by: id)
    }
}
