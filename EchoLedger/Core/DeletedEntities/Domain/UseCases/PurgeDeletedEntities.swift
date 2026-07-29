//
//  PurgeDeletedEntities.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Permanently removes every deleted-entity trace for the current user.
/// Called as part of full account deletion, since deleting the user document doesn't
/// cascade to its subcollections.
final class PurgeDeletedEntities {

    private let repository: DeletedEntityProviding

    /// - Parameter repository: The data contract for deleted-entity persistence.
    init(repository: DeletedEntityProviding) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.purge()
    }
}
