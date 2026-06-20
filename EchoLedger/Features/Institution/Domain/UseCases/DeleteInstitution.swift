//
//  DeleteInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Permanently deletes an institution, all its accounts, and all transactions linked to those accounts.
/// Cascade order: transactions → accounts → institution.
final class DeleteInstitution {

    // MARK: Dependencies
    private let repository: InstitutionProviding
    private let getAccounts: GetAccounts
    private let deleteAccount: DeleteAccountRule

    // MARK: Init
    /// - Parameters:
    ///   - repository: The data contract for institution persistence.
    ///   - getAccounts: UseCase for fetching all accounts of an institution.
    ///   - deleteAccount: Rule that cascades each account's deletion to its transactions.
    init(repository: InstitutionProviding,
         getAccounts: GetAccounts,
         deleteAccount: DeleteAccountRule) {
        self.repository = repository
        self.getAccounts = getAccounts
        self.deleteAccount = deleteAccount
    }

    // MARK: Execute
    /// Deletes an institution and all its associated accounts and transactions permanently.
    /// - Parameter id: The unique identifier of the institution to delete.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        let accounts = try await getAccounts.execute(for: id, filter: .all)
        for account in accounts {
            try await deleteAccount.execute(id: account.id)
        }
        try await repository.delete(by: id)
    }
}
