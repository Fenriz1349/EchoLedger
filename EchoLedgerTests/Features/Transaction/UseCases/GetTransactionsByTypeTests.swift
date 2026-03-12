//
//  GetTransactionsByTypeTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import XCTest
@testable import EchoLedger

// MARK: - GetTransactionsByTypeTests
final class GetTransactionsByTypeTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionRepositoryDouble!
    private var useCase: GetTransactionsByType!
    private let accountId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionRepositoryDouble()
        useCase = GetTransactionsByType(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds a transaction of a given type linked to the shared accountId.
    private func seedTransaction(type: TransactionType, amount: Decimal = 30) async throws {
        let id = UUID()
        let split = await TransactionSplit(transactionId: id, accountId: accountId, amount: amount)
        let transaction = await Transaction(id: id, label: "Test", date: Date(), totalAmount: amount, isExpense: true, type: type, splits: [split])
        try await repository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that only transactions matching the given type are returned.
    func test_execute_returnsOnlyMatchingType() async throws {
        try await seedTransaction(type: .restaurant)
        try await seedTransaction(type: .travel)
        try await seedTransaction(type: .restaurant)

        let result = try await useCase.execute(for: accountId, type: .restaurant)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.type == .restaurant })
    }

    /// Verifies that an empty result is returned when no transactions match the type.
    func test_execute_noMatchingType_returnsEmpty() async throws {
        try await seedTransaction(type: .travel)

        let result = try await useCase.execute(for: accountId, type: .restaurant)
        XCTAssertTrue(result.isEmpty)
    }
}

