//
//  GetTransactionsByCategoryTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import XCTest
@testable import EchoLedger

final class GetTransactionsByCategoryTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionDouble!
    private var useCase: GetTransactionsByCategory!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = GetTransactionsByCategory(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds a transaction of a given category belonging to the shared userId.
    private func seedTransaction(category: TransactionCategory, amount: Double = 30) async throws {
        let split = await TransactionSplit(accountId: UUID(), amount: amount)
        let transaction = await Transaction(userId: userId,
                                            label: "Test",
                                            date: Date(),
                                            totalAmount: amount,
                                            isExpense: true,
                                            category: category,
                                            splits: [split])
        try await repository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that only transactions matching the given category are returned.
    func test_execute_returnsOnlyMatchingCategory() async throws {
        try await seedTransaction(category: .restaurant)
        try await seedTransaction(category: .travel)
        try await seedTransaction(category: .restaurant)
        let result = try await useCase.execute(for: userId, category: .restaurant)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.category == .restaurant })
    }

    /// Verifies that an empty result is returned when no transactions match the category.
    func test_execute_noMatchingCategory_returnsEmpty() async throws {
        try await seedTransaction(category: .travel)
        let result = try await useCase.execute(for: userId, category: .restaurant)
        XCTAssertTrue(result.isEmpty)
    }
}
