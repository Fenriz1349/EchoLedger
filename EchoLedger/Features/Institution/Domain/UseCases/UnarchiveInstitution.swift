//
//  UnarchiveInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Restores an archived institution and all its accounts to active status.
final class UnarchiveInstitution {

    private let institutionRepository: InstitutionProviding
    private let accountRepository: AccountProviding

    /// - Parameters:
    ///   - institutionRepository: The data contract for institution persistence.
    ///   - accountRepository: The data contract for account persistence.
    init(institutionRepository: InstitutionProviding, accountRepository: AccountProviding) {
        self.institutionRepository = institutionRepository
        self.accountRepository = accountRepository
    }

    /// Unarchives an institution and cascades the operation to all its accounts.
    /// - Parameter id: The unique identifier of the institution to unarchive.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        let accounts = try await accountRepository.fetchAll(for: id)
        for account in accounts {
            let unarchived = Account(
                id: account.id,
                institutionId: account.institutionId,
                name: account.name,
                category: account.category,
                isArchived: false,
                updatedAt: Date()
            )
            try await accountRepository.update(unarchived)
        }
        try await institutionRepository.unarchive(by: id)
    }
}
