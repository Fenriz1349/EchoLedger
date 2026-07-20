//
//  ArchiveAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class ArchiveAccountTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: ArchiveAccount!

    override func setUp() {
        super.setUp()
        repository = AccountDouble()
        useCase = ArchiveAccount(repository: repository)
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
    /// Verifies that the account is marked as archived after execution.
    func test_execute_existingId_accountIsArchived() async throws {
        let id = try await seedAccount()
        try await useCase.execute(id: id)
        let account = try await repository.fetch(by: id)
        XCTAssertTrue(account.isArchived)
    }

    /// Verifies that deleting an unknown id throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
            XCTAssertEqual((error as? AccountError)?.errorDescription, "Compte introuvable.")
        }
    }
}
