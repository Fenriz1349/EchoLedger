//
//  AddTransactionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import XCTest
@testable import EchoLedger

// MARK: - AddTransactionTests
final class AddTransactionTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionRepositoryDouble!
    private var useCase: AddTransaction!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionRepositoryDouble()
        useCase = AddTransaction(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Returns a valid split for a given account id and amount.
    private func makeSplit(accountId: UUID = UUID(), amount: Decimal = 30) -> TransactionSplit {
        TransactionSplit(accountId: accountId, amount: amount)
    }

    // MARK: Success
    /// Verifies that a valid transaction is saved to the repository.
    func test_execute_validInput_callsSave() async throws {
        let split = makeSplit(amount: 30)
        try await useCase.execute(
            userId: userId,
            label: "Restaurant midi",
            date: Date(),
            totalAmount: 30,
            isExpense: true,
            type: .restaurant,
            splits: [split]
        )
        XCTAssertTrue(repository.didCallSave)
    }

    // MARK: Label Validation
    /// Verifies that an empty label throws emptyLabel.
    func test_execute_emptyLabel_throwsEmptyLabel() async {
        let split = makeSplit(amount: 30)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, label: "", date: Date(), totalAmount: 30, isExpense: true, type: .restaurant, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyLabel)
        }
    }

    /// Verifies that a whitespace-only label throws emptyLabel.
    func test_execute_whitespaceLabel_throwsEmptyLabel() async {
        let split = makeSplit(amount: 30)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, label: "   ", date: Date(), totalAmount: 30, isExpense: true, type: .restaurant, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyLabel)
        }
    }

    // MARK: Amount Validation
    /// Verifies that a zero totalAmount throws invalidTotalAmount.
    func test_execute_zeroTotalAmount_throwsInvalidTotalAmount() async {
        let split = makeSplit(amount: 0)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, label: "Test", date: Date(), totalAmount: 0, isExpense: true, type: .other, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidTotalAmount)
        }
    }

    /// Verifies that a negative totalAmount throws invalidTotalAmount.
    func test_execute_negativeTotalAmount_throwsInvalidTotalAmount() async {
        let split = makeSplit(amount: 10)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, label: "Test", date: Date(), totalAmount: -10, isExpense: true, type: .other, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidTotalAmount)
        }
    }

    // MARK: Split Validation
    /// Verifies that an empty splits array throws missingSplits.
    func test_execute_emptySplits_throwsMissingSplits() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, label: "Test", date: Date(), totalAmount: 30, isExpense: true, type: .other, splits: [])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .missingSplits)
        }
    }

    /// Verifies that a split with a zero amount throws invalidSplitAmount.
    func test_execute_zeroSplitAmount_throwsInvalidSplitAmount() async {
        let split = makeSplit(amount: 0)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, label: "Test", date: Date(), totalAmount: 30, isExpense: true, type: .other, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidSplitAmount)
        }
    }

    /// Verifies that splits not summing to totalAmount throws splitAmountMismatch.
    func test_execute_splitMismatch_throwsSplitAmountMismatch() async {
        let split = makeSplit(amount: 20)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, label: "Test", date: Date(), totalAmount: 30, isExpense: true, type: .other, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .splitAmountMismatch)
        }
    }

    /// Verifies that multiple splits summing to totalAmount succeed.
    func test_execute_multipleSplits_sumMatchesTotalAmount_succeeds() async throws {
        let split1 = makeSplit(amount: 15)
        let split2 = makeSplit(amount: 15)
        try await useCase.execute(
            userId: userId,
            label: "Restaurant",
            date: Date(),
            totalAmount: 30,
            isExpense: true,
            type: .restaurant,
            splits: [split1, split2]
        )
        XCTAssertTrue(repository.didCallSave)
    }
}

// MARK: - XCTAssertThrowsErrorAsync Helper
/// Async variant of XCTAssertThrowsError for use with async throwing functions.
func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error but none was thrown. \(message())", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
