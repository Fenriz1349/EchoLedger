//
//  UnarchiveInstitutionRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UnarchiveInstitutionRuleTests: XCTestCase {

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var rule: UnarchiveInstitutionRule!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        rule = UnarchiveInstitutionRule(
            getAccounts: GetAccounts(repository: accountRepository),
            unarchiveAccount: UnarchiveAccount(repository: accountRepository),
            unarchiveInstitution: UnarchiveInstitution(repository: institutionRepository)
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an archived institution with two archived accounts.
    private func seed() async throws {
        try await institutionRepository.save(TestData.institution(id: institutionId, isArchived: true))
        try await accountRepository.save(TestData.account(institutionId: institutionId, isArchived: true))
        try await accountRepository.save(TestData.account(institutionId: institutionId, isArchived: true))
    }

    // MARK: Tests
    /// Verifies that the institution is restored to active status.
    func test_execute_unarchivesInstitution() async throws {
        try await seed()
        try await rule.execute(id: institutionId)
        let institution = try await institutionRepository.fetch(by: institutionId)
        XCTAssertFalse(institution.isArchived)
    }

    /// Verifies that all of the institution's accounts are restored in cascade.
    func test_execute_unarchivesLinkedAccounts() async throws {
        try await seed()
        try await rule.execute(id: institutionId)
        let accounts = try await accountRepository.fetchAll(for: institutionId)
        XCTAssertTrue(accounts.allSatisfy { !$0.isArchived })
    }
}
