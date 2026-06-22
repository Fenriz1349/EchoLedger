//
//  DeleteAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteAccountTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: DeleteAccount!
    private let accountId = UUID()

    override func setUp() {
        super.setUp()
        repository = AccountDouble()
        useCase = DeleteAccount(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func seedAccount() async throws {
        try await repository.save(TestData.account(id: accountId))
    }

    // MARK: Tests
    /// Verifies that the account record is removed.
    func test_execute_existingId_accountDeleted() async throws {
        try await seedAccount()
        try await useCase.execute(id: accountId)
        await XCTAssertThrowsErrorAsync(
            try await repository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }

    /// Verifies that deleting an unknown account throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }
}
