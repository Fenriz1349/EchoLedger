//
//  DeleteAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Handles the deletion of an account permanently.
final class DeleteAccount {

    // MARK: Dependencies
    private let repository: AccountProviding

    // MARK: Init
    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Deletes an account permanently.
    /// - Parameter id: The unique identifier of the account to delete.
    /// - Throws: `AccountError.notFound` if no account matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
