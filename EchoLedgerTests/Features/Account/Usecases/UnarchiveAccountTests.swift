//
//  UnarchiveAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UnarchiveAccountTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: UnarchiveAccount!
    private let accountId = UUID()

    override func setUp() {
        super.setUp()
        repository = AccountDouble()
        useCase = UnarchiveAccount(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func seedArchivedAccount() async throws {
        try await repository.save(TestData.account(id: accountId, isArchived: true))
    }

    // MARK: Tests
    /// Verifies that the account is restored to active status.
    func test_execute_unarchivesAccount() async throws {
        try await seedArchivedAccount()
        try await useCase.execute(id: accountId)
        let account = try await repository.fetch(by: accountId)
        XCTAssertFalse(account.isArchived)
    }

    /// Verifies that unarchiving an unknown account throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }
}
