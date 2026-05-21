//
//  UnarchiveAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import Foundation

/// Restores an archived account to active status.
final class UnarchiveAccount {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// Unarchives an account by marking it as active.
    /// - Parameter id: The unique identifier of the account to unarchive.
    /// - Throws: `AccountError.notFound` if no account matches the identifier.
    func execute(id: UUID) async throws {
        let account = try await repository.fetch(by: id)
        let unarchived = Account(
            id: account.id,
            institutionId: account.institutionId,
            name: account.name,
            category: account.category,
            isArchived: false,
            updatedAt: Date()
        )
        try await repository.update(unarchived)
    }
}
