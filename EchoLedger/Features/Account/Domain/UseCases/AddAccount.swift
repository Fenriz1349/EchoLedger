//
//  AddAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Handles the creation of a new account for a given institution.
/// Enforces all business rules before persisting.
final class AddAccount {

    // MARK: Dependencies
    private let repository: AccountProviding

    // MARK: Init
    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Creates and persists a new account.
    /// - Parameters:
    ///   - institutionId: The identifier of the institution this account belongs to.
    ///   - name: Name of the account. Must be between 2 and 50 characters.
    ///   - type: Category of the account.
    /// - Throws: `AccountError` if any business rule is violated.
    func execute(
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
        guard !existing.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else {
            throw AccountError.duplicateName
        }

        let account = Account(
            institutionId: institutionId,
            name: trimmed,
            type: type
        )
        try await repository.save(account)
    }
}
