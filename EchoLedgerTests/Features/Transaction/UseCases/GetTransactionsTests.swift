//
//  GetTransactionsTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 12/03/2026.
//

import XCTest
@testable import EchoLedger

// MARK: - GetTransactionsTests
final class GetTransactionsTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionRepositoryDouble!
    private var useCase: GetTransactions!
    private let accountId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionRepositoryDouble()
        useCase = GetTransactions(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds a transaction linked to the shared accountId.
    private func seedTransaction(label: String = "Test", amount: Decimal = 30) async throws {
        let id = UUID()
        let split = TransactionSplit(transactionId: id, accountId: accountId, amount: amount)
        let transaction = Transaction(id: id, label: label, date: Date(), totalAmount: amount, isExpense: true, type: .other, splits: [split])
        try await repository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that all transactions linked to the account are returned.
    func test_execute_returnsAllTransactionsForAccount() async throws {
        try await seedTransaction(label: "Premier")
        try await seedTransaction(label: "Deuxième")
        let result = try await useCase.execute(for: accountId)
        XCTAssertEqual(result.count, 2)
    }

    /// Verifies that transactions linked to a different account are not returned.
    func test_execute_doesNotReturnTransactionsFromOtherAccount() async throws {
        try await seedTransaction()
        let result = try await useCase.execute(for: UUID())
        XCTAssertTrue(result.isEmpty)
    }

    /// Verifies that an empty array is returned when no transactions exist.
    func test_execute_noTransactions_returnsEmpty() async throws {
        let result = try await useCase.execute(for: accountId)
        XCTAssertTrue(result.isEmpty)
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = TransactionError.notFound
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(for: accountId)
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }
}
