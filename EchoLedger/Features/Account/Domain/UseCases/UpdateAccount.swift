//
//  UpdateAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Handles updating an existing account.
/// Re-enforces all business rules before persisting.
final class UpdateAccount {

    // MARK: Dependencies
    private let repository: AccountProviding

    // MARK: Init
    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Updates an existing account with new values.
    /// - Parameter input: The data required to update the account.
    /// - Throws: `AccountError` if any business rule is violated.
    func execute(_ input: UpdateAccountInput) async throws {
        let trimmed = input.name.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            throw AccountError.nameTooShort
        }
        guard trimmed.count <= 50 else {
            throw AccountError.nameTooLong
        }
        let existing = try await repository.fetchAll(for: input.institutionId)
        guard !existing.contains(where: { $0.name.lowercased() == trimmed.lowercased() && $0.id != input.id }) else {
            throw AccountError.duplicateName
        }

        let updated = Account(
            id: input.id,
            institutionId: input.institutionId,
            name: trimmed,
            category: input.category
        )
        try await repository.update(updated)
    }
}
