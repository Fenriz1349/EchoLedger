//
//  GetAccountsTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class GetAccountsTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: GetAccounts!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        repository = AccountDouble()
        useCase = GetAccounts(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an account belonging to the shared institutionId.
    private func seedAccount(name: String = "Livret A") async throws {
        let account = Account(institutionId: institutionId, name: name, category: .savings)
        try await repository.save(account)
    }

    // MARK: Tests
    /// Verifies that all accounts belonging to the institution are returned.
    func test_execute_returnsAllAccountsForInstitution() async throws {
        try await seedAccount(name: "Livret A")
        try await seedAccount(name: "PEL")
        let result = try await useCase.execute(for: institutionId)
        XCTAssertEqual(result.count, 2)
    }

    /// Verifies that accounts belonging to a different institution are not returned.
    func test_execute_doesNotReturnAccountsFromOtherInstitution() async throws {
        try await seedAccount()
        let result = try await useCase.execute(for: UUID())
        XCTAssertTrue(result.isEmpty)
    }

    /// Verifies that an empty array is returned when no accounts exist.
    func test_execute_noAccounts_returnsEmpty() async throws {
        let result = try await useCase.execute(for: institutionId)
        XCTAssertTrue(result.isEmpty)
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = AccountError.notFound
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(for: institutionId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }
}
