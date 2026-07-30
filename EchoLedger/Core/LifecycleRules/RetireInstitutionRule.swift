//
//  RetireInstitutionRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Deletes an institution while preserving history: detaches each of its accounts via
/// `RetireAccountRule` (keeping their transactions), records the institution's own name,
/// then deletes the institution record. Lives above the features so each feature use case
/// stays single-aggregate.
final class RetireInstitutionRule {

    private let getInstitution: GetInstitution
    private let getAccounts: GetAccounts
    private let retireAccountRule: RetireAccountRule
    private let recordDeletedEntity: RecordDeletedEntity
    private let deleteInstitution: DeleteInstitution

    init(getInstitution: GetInstitution,
         getAccounts: GetAccounts,
         retireAccountRule: RetireAccountRule,
         recordDeletedEntity: RecordDeletedEntity,
         deleteInstitution: DeleteInstitution) {
        self.getInstitution = getInstitution
        self.getAccounts = getAccounts
        self.retireAccountRule = retireAccountRule
        self.recordDeletedEntity = recordDeletedEntity
        self.deleteInstitution = deleteInstitution
    }

    /// - Parameter id: The unique identifier of the institution to detach and delete.
    func execute(id: UUID) async throws {
        let institution = try await getInstitution.execute(id: id)
        let accounts = try await getAccounts.execute(for: id, filter: .all)
        for account in accounts {
            try await retireAccountRule.execute(id: account.id)
        }
        try await recordDeletedEntity.execute(id: institution.id, name: institution.name, kind: .institution)
        try await deleteInstitution.execute(id: id)
    }
}
