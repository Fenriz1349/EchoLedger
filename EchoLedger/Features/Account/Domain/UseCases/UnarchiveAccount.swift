//
//  UnarchiveAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import Foundation

/// Restores an archived account to active status.
/// Also unarchives the parent institution if it was archived.
final class UnarchiveAccount {

    private let accountRepository: AccountProviding
    private let institutionRepository: InstitutionProviding

    /// - Parameters:
    ///   - accountRepository: The data contract for account persistence.
    ///   - institutionRepository: The data contract for institution persistence.
    init(accountRepository: AccountProviding, institutionRepository: InstitutionProviding) {
        self.accountRepository = accountRepository
        self.institutionRepository = institutionRepository
    }

    /// Unarchives an account by marking it as active.
    /// If the parent institution is also archived, it is automatically unarchived.
    /// - Parameter id: The unique identifier of the account to unarchive.
    /// - Throws: `AccountError.notFound` if no account matches the identifier.
    func execute(id: UUID) async throws {
        let account = try await accountRepository.fetch(by: id)
        let unarchived = Account(
            id: account.id,
            institutionId: account.institutionId,
            name: account.name,
            category: account.category,
            isArchived: false,
            updatedAt: Date()
        )
        try await accountRepository.update(unarchived)

        let institution = try await institutionRepository.fetch(by: account.institutionId)
        if institution.isArchived {
            try await institutionRepository.unarchive(by: institution.id)
        }
    }
}
