//
//  GetTransactionsByAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class GetTransactionsByAccountTests: XCTestCase {

    private var repository: TransactionDouble!
    private var useCase: GetTransactionsByAccount!
    private let userId = UUID()
    private let accountId = UUID()

    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = GetTransactionsByAccount(getTransactions: GetTransactions(repository: repository))
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds a single-split transaction allocated to the given account.
    private func seedTransaction(label: String = "Test", splitOn account: UUID) async throws {
        let split = TransactionSplit(accountId: account, amount: 30)
        let transaction = Transaction(userId: userId,
                                      label: label,
                                      date: Date(),
                                      totalAmount: 30,
                                      isExpense: true,
                                      category: .other,
                                      splits: [split])
        try await repository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that only transactions with a split on the account are returned.
    func test_execute_returnsOnlyTransactionsForAccount() async throws {
        try await seedTransaction(label: "Mine", splitOn: accountId)
        try await seedTransaction(label: "Other", splitOn: UUID())
        let result = try await useCase.execute(for: userId, accountId: accountId)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.label, "Mine")
    }

    /// Verifies that a transaction split across the account and another is included.
    func test_execute_includesMultiAccountTransaction() async throws {
        let splits = [
            TransactionSplit(accountId: accountId, amount: 15),
            TransactionSplit(accountId: UUID(), amount: 15)
        ]
        let transaction = Transaction(userId: userId,
                                      label: "Split",
                                      date: Date(),
                                      totalAmount: 30,
                                      isExpense: true,
                                      category: .other,
                                      splits: splits)
        try await repository.save(transaction)
        let result = try await useCase.execute(for: userId, accountId: accountId)
        XCTAssertEqual(result.count, 1)
    }

    /// Verifies that no transaction on the account yields an empty result.
    func test_execute_noMatch_returnsEmpty() async throws {
        try await seedTransaction(splitOn: UUID())
        let result = try await useCase.execute(for: userId, accountId: accountId)
        XCTAssertTrue(result.isEmpty)
    }
}
