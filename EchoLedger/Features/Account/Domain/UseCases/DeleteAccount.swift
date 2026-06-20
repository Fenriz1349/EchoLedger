//
//  DeleteAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/05/2026.
//

import Foundation

/// Permanently deletes a single account record. Cleaning up the transactions allocated to it
/// is orchestrated by `DeleteAccountRule`.
final class DeleteAccount {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the account to delete.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
