//
//  RetireAccountRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 29/07/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class RetireAccountRuleTests: XCTestCase {

    private var accountRepository: AccountDouble!
    private var institutionRepository: InstitutionDouble!
    private var deletedEntityRepository: DeletedEntityDouble!
    private var rule: RetireAccountRule!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        accountRepository = AccountDouble()
        institutionRepository = InstitutionDouble()
        deletedEntityRepository = DeletedEntityDouble()
        rule = RetireAccountRule(
            getAccount: GetAccount(repository: accountRepository),
            getInstitution: GetInstitution(repository: institutionRepository),
            recordDeletedEntity: RecordDeletedEntity(repository: deletedEntityRepository),
            deleteAccount: DeleteAccount(repository: accountRepository)
        )
    }

    override func tearDown() {
        accountRepository = nil
        institutionRepository = nil
        deletedEntityRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Tests

    /// Verifies that the account record is deleted.
    func test_execute_deletesAccount() async throws {
        let institutionId = UUID()
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId))
        let accountId = UUID()
        try await accountRepository.save(TestData.account(id: accountId, institutionId: institutionId))

        try await rule.execute(id: accountId)

        await XCTAssertThrowsErrorAsync(
            try await accountRepository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }

    /// Verifies that the account's name and its institution's name are recorded before deletion.
    func test_execute_recordsAccountNameAndInstitutionName() async throws {
        let institutionId = UUID()
        try await institutionRepository.save(
            TestData.institution(id: institutionId, userId: userId, name: "BNP Paribas")
        )
        let accountId = UUID()
        try await accountRepository.save(
            TestData.account(id: accountId, institutionId: institutionId, name: "Livret A")
        )

        try await rule.execute(id: accountId)

        let recorded = try await deletedEntityRepository.fetch(by: accountId)
        XCTAssertEqual(recorded?.name, "Livret A")
        XCTAssertEqual(recorded?.kind, .account)
        XCTAssertEqual(recorded?.institutionName, "BNP Paribas")
    }

    /// Verifies that an unknown account id throws instead of silently recording/deleting anything.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await rule.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }
}
