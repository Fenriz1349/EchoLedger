//
//  ArchiveInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Archives an institution and all its accounts by marking them as inactive.
final class ArchiveInstitution {

    private let institutionRepository: InstitutionProviding
    private let accountRepository: AccountProviding

    /// - Parameters:
    ///   - institutionRepository: The data contract for institution persistence.
    ///   - accountRepository: The data contract for account persistence.
    init(institutionRepository: InstitutionProviding, accountRepository: AccountProviding) {
        self.institutionRepository = institutionRepository
        self.accountRepository = accountRepository
    }

    /// Archives an institution and cascades the operation to all its accounts.
    /// - Parameter id: The unique identifier of the institution to archive.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        let accounts = try await accountRepository.fetchAll(for: id)
        for account in accounts {
            let archived = Account(
                id: account.id,
                institutionId: account.institutionId,
                name: account.name,
                category: account.category,
                isArchived: true,
                updatedAt: Date()
            )
            try await accountRepository.update(archived)
        }
        try await institutionRepository.archive(by: id)
    }
}
