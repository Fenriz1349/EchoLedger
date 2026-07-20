//
//  UnarchiveAccountRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UnarchiveAccountRuleTests: XCTestCase {

    private var accountRepository: AccountDouble!
    private var institutionRepository: InstitutionDouble!
    private var rule: UnarchiveAccountRule!
    private let accountId = UUID()
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        accountRepository = AccountDouble()
        institutionRepository = InstitutionDouble()
        rule = UnarchiveAccountRule(
            getAccount: GetAccount(repository: accountRepository),
            unarchiveAccount: UnarchiveAccount(repository: accountRepository),
            getInstitution: GetInstitution(repository: institutionRepository),
            unarchiveInstitution: UnarchiveInstitution(repository: institutionRepository)
        )
    }

    override func tearDown() {
        accountRepository = nil
        institutionRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an archived account and its institution (archived or not).
    private func seed(institutionArchived: Bool) async throws {
        try await institutionRepository.save(TestData.institution(id: institutionId, isArchived: institutionArchived))
        try await accountRepository.save(TestData.account(id: accountId, institutionId: institutionId, isArchived: true))
    }

    // MARK: Tests
    /// Verifies that the account is restored to active status.
    func test_execute_unarchivesAccount() async throws {
        try await seed(institutionArchived: false)
        try await rule.execute(id: accountId)
        let account = try await accountRepository.fetch(by: accountId)
        XCTAssertFalse(account.isArchived)
    }

    /// Verifies that an archived parent institution is reactivated.
    func test_execute_archivedParent_isReactivated() async throws {
        try await seed(institutionArchived: true)
        try await rule.execute(id: accountId)
        let institution = try await institutionRepository.fetch(by: institutionId)
        XCTAssertFalse(institution.isArchived)
    }
}
