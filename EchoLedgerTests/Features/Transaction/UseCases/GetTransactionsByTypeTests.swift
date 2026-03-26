//
//  GetTransactionsByTypeTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import XCTest
@testable import EchoLedger

final class GetTransactionsByTypeTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionDouble!
    private var useCase: GetTransactionsByType!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = GetTransactionsByType(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds a transaction of a given type belonging to the shared userId.
    private func seedTransaction(type: TransactionType, amount: Decimal = 30) async throws {
        let split = await TransactionSplit(accountId: UUID(), amount: amount)
        let transaction = await Transaction(userId: userId,
                                            label: "Test",
                                            date: Date(),
                                            totalAmount: amount,
                                            isExpense: true,
                                            type: type,
                                            splits: [split])
        try await repository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that only transactions matching the given type are returned.
    func test_execute_returnsOnlyMatchingType() async throws {
        try await seedTransaction(type: .restaurant)
        try await seedTransaction(type: .travel)
        try await seedTransaction(type: .restaurant)
        let result = try await useCase.execute(for: userId, type: .restaurant)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.type == .restaurant })
    }

    /// Verifies that an empty result is returned when no transactions match the type.
    func test_execute_noMatchingType_returnsEmpty() async throws {
        try await seedTransaction(type: .travel)
        let result = try await useCase.execute(for: userId, type: .restaurant)
        XCTAssertTrue(result.isEmpty)
    }
}
