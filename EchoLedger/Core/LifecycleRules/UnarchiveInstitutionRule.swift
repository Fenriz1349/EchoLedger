//
//  UnarchiveInstitutionRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Unarchives an institution and all of its accounts. Lives above the features so each feature use
/// case stays single-aggregate.
final class UnarchiveInstitutionRule {

    private let getAccounts: GetAccounts
    private let unarchiveAccount: UnarchiveAccount
    private let unarchiveInstitution: UnarchiveInstitution

    init(getAccounts: GetAccounts,
         unarchiveAccount: UnarchiveAccount,
         unarchiveInstitution: UnarchiveInstitution) {
        self.getAccounts = getAccounts
        self.unarchiveAccount = unarchiveAccount
        self.unarchiveInstitution = unarchiveInstitution
    }

    /// - Parameter id: The unique identifier of the institution to unarchive.
    func execute(id: UUID) async throws {
        let accounts = try await getAccounts.execute(for: id, filter: .all)
        for account in accounts {
            try await unarchiveAccount.execute(id: account.id)
        }
        try await unarchiveInstitution.execute(id: id)
    }
}
