//
//  DeleteTransactionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 12/03/2026.
//

import XCTest
@testable import EchoLedger

final class DeleteTransactionTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionDouble!
    private var useCase: DeleteTransaction!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = DeleteTransaction(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds and returns a transaction with a known id.
    private func seedTransaction() async throws -> UUID {
        let id = UUID()
        let split = await TransactionSplit(accountId: UUID(), amount: 30)
        let transaction = await Transaction(id: id,
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
    /// Verifies that an existing transaction is deleted and didCallDelete is set.
    func test_execute_existingId_callsDelete() async throws {
        let id = try await seedTransaction()
        try await useCase.execute(id: id)
        XCTAssertTrue(repository.didCallDelete)
    }

    /// Verifies that the transaction is no longer fetchable after deletion.
    func test_execute_existingId_transactionNoLongerExists() async throws {
        let id = try await seedTransaction()
        try await useCase.execute(id: id)
        await XCTAssertThrowsErrorAsync(
            try await repository.fetch(by: id)
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }

    /// Verifies that deleting an unknown id throws notFound.
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
