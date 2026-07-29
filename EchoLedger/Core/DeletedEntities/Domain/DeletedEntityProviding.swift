//
//  DeletedEntityProviding.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Defines the contract for deleted-entity name persistence.
/// The Domain layer depends only on this protocol — it has no knowledge of SwiftData or Firebase.
/// Conforming types live in the Data layer.
protocol DeletedEntityProviding {

    /// Persists the name of an entity that was just permanently deleted.
    /// - Parameter entity: The deleted entity's id, name, and kind.
    func save(_ entity: DeletedEntity) async throws

    /// Fetches a deleted entity's trace by its original identifier.
    /// - Parameter id: The identifier the entity had before being deleted.
    /// - Returns: The matching trace, or `nil` if this id was never deleted (or predates this feature).
    func fetch(by id: UUID) async throws -> DeletedEntity?
}
