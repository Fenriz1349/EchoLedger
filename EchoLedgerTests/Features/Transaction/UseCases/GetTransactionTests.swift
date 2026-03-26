//
//  GetTransactionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 12/03/2026.
//

import XCTest
@testable import EchoLedger

final class GetTransactionTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionDouble!
    private var useCase: GetTransaction!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = GetTransaction(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds and returns a transaction with a known id.
    @MainActor
    private func seedTransaction() async throws -> UUID {
        let id = UUID()
        let split = TransactionSplit(accountId: UUID(), amount: 30)
        let transaction = Transaction(id: id,
                                      userId: userId,
                                      label: "Test",
                                      date: Date(),
                                      totalAmount: 30,
                                      isExpense: true,
                                      type: .other,
                                      splits: [split])
        try await repository.save(transaction)
        return id
    }

    // MARK: Tests
    /// Verifies that the correct transaction is returned for a known id.
    func test_execute_existingId_returnsTransaction() async throws {
        let id = try await seedTransaction()
        let result = try await useCase.execute(id: id)
        let resultId = await result.id
        XCTAssertEqual(resultId, id)
    }

    /// Verifies that the returned transaction has the expected label.
    func test_execute_existingId_returnsCorrectLabel() async throws {
        let id = try await seedTransaction()
        let result = try await useCase.execute(id: id)
        let resultLabel = await result.label
        XCTAssertEqual(resultLabel, "Test")
    }

    /// Verifies that notFound is thrown when no transaction matches the id.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = TransactionError.notFound
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }
}
