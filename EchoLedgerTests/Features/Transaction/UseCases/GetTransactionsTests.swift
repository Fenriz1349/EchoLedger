//
//  GetTransactionsTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 12/03/2026.
//

import XCTest
@testable import EchoLedger

final class GetTransactionsTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionDouble!
    private var useCase: GetTransactions!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = GetTransactions(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds a transaction belonging to the shared userId.
    private func seedTransaction(label: String = "Test", amount: Double = 30) async throws {
        let split = await TransactionSplit(accountId: UUID(), amount: amount)
        let transaction = await Transaction(userId: userId,
                                            label: label,
                                            date: Date(),
                                            totalAmount: amount,
                                            isExpense: true,
                                            category: .other,
                                            splits: [split])
        try await repository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that all transactions belonging to the user are returned.
    func test_execute_returnsAllTransactionsForUser() async throws {
        try await seedTransaction(label: "Premier")
        try await seedTransaction(label: "Deuxième")
        let result = try await useCase.execute(for: userId)
        XCTAssertEqual(result.count, 2)
    }

    /// Verifies that transactions belonging to a different user are not returned.
    func test_execute_doesNotReturnTransactionsFromOtherUser() async throws {
        try await seedTransaction()
        let result = try await useCase.execute(for: UUID())
        XCTAssertTrue(result.isEmpty)
    }

    /// Verifies that an empty array is returned when no transactions exist.
    func test_execute_noTransactions_returnsEmpty() async throws {
        let result = try await useCase.execute(for: userId)
        XCTAssertTrue(result.isEmpty)
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = TransactionError.notFound
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(for: userId)
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }
}
