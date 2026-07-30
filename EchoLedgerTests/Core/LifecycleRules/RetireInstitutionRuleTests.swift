//
//  RetireInstitutionRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 29/07/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class RetireInstitutionRuleTests: XCTestCase {

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var deletedEntityRepository: DeletedEntityDouble!
    private var rule: RetireInstitutionRule!
    private let userId = UUID()
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        deletedEntityRepository = DeletedEntityDouble()
        let retireAccountRule = RetireAccountRule(
            getAccount: GetAccount(repository: accountRepository),
            getInstitution: GetInstitution(repository: institutionRepository),
            recordDeletedEntity: RecordDeletedEntity(repository: deletedEntityRepository),
            deleteAccount: DeleteAccount(repository: accountRepository)
        )
        rule = RetireInstitutionRule(
            getInstitution: GetInstitution(repository: institutionRepository),
            getAccounts: GetAccounts(repository: accountRepository),
            retireAccountRule: retireAccountRule,
            recordDeletedEntity: RecordDeletedEntity(repository: deletedEntityRepository),
            deleteInstitution: DeleteInstitution(repository: institutionRepository)
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        deletedEntityRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an institution with one account; returns the account's id.
    @discardableResult
    private func seedTree() async throws -> UUID {
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId, name: "BNP Paribas"))
        let accountId = UUID()
        try await accountRepository.save(TestData.account(id: accountId, institutionId: institutionId, name: "Livret A"))
        return accountId
    }

    // MARK: Tests

    /// Verifies that the institution record is deleted.
    func test_execute_deletesInstitution() async throws {
        try await seedTree()

        try await rule.execute(id: institutionId)

        await XCTAssertThrowsErrorAsync(
            try await institutionRepository.fetch(by: institutionId)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }

    /// Verifies that the institution's accounts are retired (deleted, not just left behind) in cascade.
    func test_execute_retiresLinkedAccounts() async throws {
        let accountId = try await seedTree()

        try await rule.execute(id: institutionId)

        await XCTAssertThrowsErrorAsync(
            try await accountRepository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }

    /// Verifies that each retired account is recorded with the institution's name before deletion.
    func test_execute_recordsLinkedAccountWithInstitutionName() async throws {
        let accountId = try await seedTree()

        try await rule.execute(id: institutionId)

        let recorded = try await deletedEntityRepository.fetch(by: accountId)
        XCTAssertEqual(recorded?.name, "Livret A")
        XCTAssertEqual(recorded?.kind, .account)
        XCTAssertEqual(recorded?.institutionName, "BNP Paribas")
    }

    /// Verifies that the institution's own name is recorded before deletion.
    func test_execute_recordsInstitutionName() async throws {
        try await seedTree()

        try await rule.execute(id: institutionId)

        let recorded = try await deletedEntityRepository.fetch(by: institutionId)
        XCTAssertEqual(recorded?.name, "BNP Paribas")
        XCTAssertEqual(recorded?.kind, .institution)
        XCTAssertNil(recorded?.institutionName)
    }

    /// Verifies that an unknown institution id throws instead of silently recording/deleting anything.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await rule.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }
}
