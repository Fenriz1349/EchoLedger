//
//  ArchiveInstitutionRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Archives an institution and all of its accounts. Lives above the features so each feature use
/// case stays single-aggregate.
final class ArchiveInstitutionRule {

    private let getAccounts: GetAccounts
    private let archiveAccount: ArchiveAccount
    private let archiveInstitution: ArchiveInstitution

    init(getAccounts: GetAccounts,
         archiveAccount: ArchiveAccount,
         archiveInstitution: ArchiveInstitution) {
        self.getAccounts = getAccounts
        self.archiveAccount = archiveAccount
        self.archiveInstitution = archiveInstitution
    }

    /// - Parameter id: The unique identifier of the institution to archive.
    func execute(id: UUID) async throws {
        let accounts = try await getAccounts.execute(for: id, filter: .all)
        for account in accounts {
            try await archiveAccount.execute(id: account.id)
        }
        try await archiveInstitution.execute(id: id)
    }
}
