//
//  GetAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class GetAccountTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: GetAccount!

    override func setUp() {
        super.setUp()
        repository = AccountDouble()
        useCase = GetAccount(repository: repository)
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
    /// Verifies that the correct account is returned for a known id.
    func test_execute_existingId_returnsAccount() async throws {
        let id = try await seedAccount()
        let result = try await useCase.execute(id: id)
        let resultId = result.id
        XCTAssertEqual(resultId, id)
    }

    /// Verifies that the returned account has the expected name.
    func test_execute_existingId_returnsCorrectName() async throws {
        let id = try await seedAccount()
        let result = try await useCase.execute(id: id)
        let resultName = result.name
        XCTAssertEqual(resultName, "Livret A")
    }

    /// Verifies that notFound is thrown when no account matches the id.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
            XCTAssertEqual((error as? AccountError)?.errorDescription, "Compte introuvable.")
        }
    }
}
