//
//  ArchiveAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Handles the deletion of an account permanently.
final class ArchiveAccount {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// Archives an account by marking it as inactive.
    /// - Parameter id: The unique identifier of the account to archive.
    /// - Throws: `AccountError.notFound` if no account matches the identifier.
    func execute(id: UUID) async throws {
        let account = try await repository.fetch(by: id)
        let archived = Account(
            id: account.id,
            institutionId: account.institutionId,
            name: account.name,
            category: account.category,
            isArchived: true
        )
        try await repository.update(archived)
    }
}
