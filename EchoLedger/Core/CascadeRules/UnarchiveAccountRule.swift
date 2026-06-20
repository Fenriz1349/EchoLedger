//
//  UnarchiveAccountRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Unarchives a single account, then reactivates its parent institution if that institution was
/// archived — an active account must have an active parent. Uses the pure `UnarchiveInstitution`
/// (record only), never `UnarchiveInstitutionRule`, so the sibling accounts are left untouched.
final class UnarchiveAccountRule {

    private let getAccount: GetAccount
    private let unarchiveAccount: UnarchiveAccount
    private let getInstitution: GetInstitution
    private let unarchiveInstitution: UnarchiveInstitution

    init(getAccount: GetAccount,
         unarchiveAccount: UnarchiveAccount,
         getInstitution: GetInstitution,
         unarchiveInstitution: UnarchiveInstitution) {
        self.getAccount = getAccount
        self.unarchiveAccount = unarchiveAccount
        self.getInstitution = getInstitution
        self.unarchiveInstitution = unarchiveInstitution
    }

    /// - Parameter id: The unique identifier of the account to unarchive.
    func execute(id: UUID) async throws {
        let account = try await getAccount.execute(id: id)
        try await unarchiveAccount.execute(id: id)
        let institution = try await getInstitution.execute(id: account.institutionId)
        if institution.isArchived {
            try await unarchiveInstitution.execute(id: institution.id)
        }
    }
}
