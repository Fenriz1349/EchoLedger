//
//  RetireAccountRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Deletes an account while preserving its transaction history: the account's name is recorded
/// before it's removed, and its transactions are left untouched — their splits simply keep
/// referencing an id that no longer resolves, resolved back to the recorded name for display.
/// Lives above the features so each feature use case stays single-aggregate.
final class RetireAccountRule {

    private let getAccount: GetAccount
    private let getInstitution: GetInstitution
    private let recordDeletedEntity: RecordDeletedEntity
    private let deleteAccount: DeleteAccount

    init(getAccount: GetAccount,
         getInstitution: GetInstitution,
         recordDeletedEntity: RecordDeletedEntity,
         deleteAccount: DeleteAccount) {
        self.getAccount = getAccount
        self.getInstitution = getInstitution
        self.recordDeletedEntity = recordDeletedEntity
        self.deleteAccount = deleteAccount
    }

    /// - Parameter id: The unique identifier of the account to detach and delete.
    func execute(id: UUID) async throws {
        let account = try await getAccount.execute(id: id)
        // Best-effort: the institution's current name is a display nicety, not a
        // requirement — its own retirement (if any) already handles its own trace.
        let institution = try? await getInstitution.execute(id: account.institutionId)
        try await recordDeletedEntity.execute(
            id: account.id,
            name: account.name,
            kind: .account,
            institutionName: institution?.name
        )
        try await deleteAccount.execute(id: id)
    }
}
