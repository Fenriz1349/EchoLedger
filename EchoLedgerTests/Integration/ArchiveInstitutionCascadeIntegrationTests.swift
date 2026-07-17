//
//  ArchiveInstitutionCascadeIntegrationTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
@testable import EchoLedger

/// Chains AddInstitution, AddAccount and ArchiveInstitutionRule against shared in-memory
/// repositories to verify archiving an institution cascades to its account.
@MainActor
final class ArchiveInstitutionCascadeIntegrationTests: XCTestCase {

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var addInstitution: AddInstitution!
    private var addAccount: AddAccount!
    private var archiveInstitutionRule: ArchiveInstitutionRule!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        addInstitution = AddInstitution(repository: institutionRepository)
        addAccount = AddAccount(repository: accountRepository)
        let getAccounts = GetAccounts(repository: accountRepository)
        archiveInstitutionRule = ArchiveInstitutionRule(
            getAccounts: getAccounts,
            archiveAccount: ArchiveAccount(repository: accountRepository),
            archiveInstitution: ArchiveInstitution(repository: institutionRepository)
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        addInstitution = nil
        addAccount = nil
        archiveInstitutionRule = nil
        super.tearDown()
    }

    /// Verifies that archiving an institution also archives the account created under it.
    func test_archiveInstitution_cascadesToAccount() async throws {
        try await addInstitution.execute(AddInstitutionInput(
            userId: userId, name: "BNP Paribas", category: .bank, logoURL: nil
        ))
        let institutions = try await institutionRepository.fetchAll(for: userId)
        let institutionId = try XCTUnwrap(institutions.first?.id)

        let account = try await addAccount.execute(institutionId: institutionId, name: "Compte courant", category: .checking)

        try await archiveInstitutionRule.execute(id: institutionId)

        let institution = try await institutionRepository.fetch(by: institutionId)
        let archivedAccount = try await accountRepository.fetch(by: account.id)
        XCTAssertTrue(institution.isArchived)
        XCTAssertTrue(archivedAccount.isArchived)
    }
}
