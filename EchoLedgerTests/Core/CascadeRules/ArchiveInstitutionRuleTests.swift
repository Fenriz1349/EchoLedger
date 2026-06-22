//
//  ArchiveInstitutionRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class ArchiveInstitutionRuleTests: XCTestCase {

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var rule: ArchiveInstitutionRule!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        rule = ArchiveInstitutionRule(
            getAccounts: GetAccounts(repository: accountRepository),
            archiveAccount: ArchiveAccount(repository: accountRepository),
            archiveInstitution: ArchiveInstitution(repository: institutionRepository)
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an active institution with two active accounts.
    private func seed() async throws {
        try await institutionRepository.save(TestData.institution(id: institutionId))
        try await accountRepository.save(TestData.account(institutionId: institutionId))
        try await accountRepository.save(TestData.account(institutionId: institutionId))
    }

    // MARK: Tests
    /// Verifies that the institution is archived.
    func test_execute_archivesInstitution() async throws {
        try await seed()
        try await rule.execute(id: institutionId)
        let institution = try await institutionRepository.fetch(by: institutionId)
        XCTAssertTrue(institution.isArchived)
    }

    /// Verifies that all of the institution's accounts are archived in cascade.
    func test_execute_archivesLinkedAccounts() async throws {
        try await seed()
        try await rule.execute(id: institutionId)
        let accounts = try await accountRepository.fetchAll(for: institutionId)
        XCTAssertTrue(accounts.allSatisfy { $0.isArchived })
    }
}
