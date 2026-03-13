//
//  GetTransactionsByDateRangeTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 12/03/2026.
//

import XCTest
@testable import EchoLedger

// MARK: - GetTransactionsByDateRangeTests
final class GetTransactionsByDateRangeTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionRepositoryDouble!
    private var useCase: GetTransactionsByDateRange!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionRepositoryDouble()
        useCase = GetTransactionsByDateRange(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Returns a date offset by the given number of days from today.
    private func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
    }

    /// Seeds a transaction at a given date belonging to the shared userId.
    private func seedTransaction(date: Date, amount: Decimal = 30) async throws {
        let split = await TransactionSplit(accountId: UUID(), amount: amount)
        let transaction = await Transaction(userId: userId, label: "Test", date: date, totalAmount: amount, isExpense: true, type: .other, splits: [split])
        try await repository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that only transactions within the date range are returned.
    func test_execute_returnsOnlyTransactionsInRange() async throws {
        try await seedTransaction(date: date(daysAgo: 10))
        try await seedTransaction(date: date(daysAgo: 5))
        try await seedTransaction(date: date(daysAgo: 1))
        let result = try await useCase.execute(for: userId, from: date(daysAgo: 7), to: Date())
        XCTAssertEqual(result.count, 2)
    }

    /// Verifies that an empty result is returned when no transactions fall in the range.
    func test_execute_noTransactionsInRange_returnsEmpty() async throws {
        try await seedTransaction(date: date(daysAgo: 30))
        let result = try await useCase.execute(for: userId, from: date(daysAgo: 7), to: Date())
        XCTAssertTrue(result.isEmpty)
    }

    /// Verifies that an invalid date range throws invalidDateRange.
    func test_execute_fromAfterTo_throwsInvalidDateRange() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(for: userId, from: Date(), to: date(daysAgo: 7))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidDateRange)
        }
    }
}
