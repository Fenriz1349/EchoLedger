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
    /// - Parameters:
    ///   - id: The unique identifier of the account to update.
    ///   - institutionId: The identifier of the institution this account belongs to.
    ///   - name: Updated name. Must be between 2 and 50 characters.
    ///   - type: Updated category.
    /// - Throws: `AccountError` if any business rule is violated.
    func execute(
        id: UUID,
        institutionId: UUID,
        name: String,
        type: AccountType
    ) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            throw AccountError.nameTooShort
        }
        guard trimmed.count <= 50 else {
            throw AccountError.nameTooLong
        }
        let existing = try await repository.fetchAll(for: institutionId)
        guard !existing.contains(where: { $0.name.lowercased() == trimmed.lowercased() && $0.id != id }) else {
            throw AccountError.duplicateName
        }

        let updated = Account(
            id: id,
            institutionId: institutionId,
            name: trimmed,
            type: type
        )
        try await repository.update(updated)
    }
}

