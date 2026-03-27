//
//  DeleteAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteAccountTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: DeleteAccount!

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
    /// Seeds and returns an account with a known id.
    private func seedAccount() async throws -> UUID {
        let account = Account(institutionId: UUID(), name: "Livret A", category: .savings)
        try await repository.save(account)
        return account.id
    }

    // MARK: Tests
    /// Verifies that an existing account is deleted and didCallDelete is set.
    func test_execute_existingId_callsDelete() async throws {
        let id = try await seedAccount()
        try await useCase.execute(id: id)
        XCTAssertTrue(repository.didCallDelete)
    }

    /// Verifies that the account is no longer fetchable after deletion.
    func test_execute_existingId_accountNoLongerExists() async throws {
        let id = try await seedAccount()
        try await useCase.execute(id: id)
        await XCTAssertThrowsErrorAsync(
            try await repository.fetch(by: id)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }

    /// Verifies that deleting an unknown id throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }
}
