//
//  DeleteInstitutionRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Orchestrates the full deletion of an institution: deletes each of its accounts — cascading to
/// their transactions through `DeleteAccountRule` — then deletes the institution record.
/// Lives above the features so each feature use case stays single-aggregate.
final class DeleteInstitutionRule {

    private let getAccounts: GetAccounts
    private let deleteAccountRule: DeleteAccountRule
    private let deleteInstitution: DeleteInstitution

    init(getAccounts: GetAccounts,
         deleteAccountRule: DeleteAccountRule,
         deleteInstitution: DeleteInstitution) {
        self.getAccounts = getAccounts
        self.deleteAccountRule = deleteAccountRule
        self.deleteInstitution = deleteInstitution
    }

    /// - Parameter id: The unique identifier of the institution to delete.
    func execute(id: UUID) async throws {
        let accounts = try await getAccounts.execute(for: id, filter: .all)
        for account in accounts {
            try await deleteAccountRule.execute(id: account.id)
        }
        try await deleteInstitution.execute(id: id)
    }
}
