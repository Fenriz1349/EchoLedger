//
//  UpdateTransactionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import XCTest
@testable import EchoLedger

// MARK: - UpdateTransactionTests
final class UpdateTransactionTests: XCTestCase {

    // MARK: Properties
    private var repository: TransactionRepositoryDouble!
    private var useCase: UpdateTransaction!

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = TransactionRepositoryDouble()
        useCase = UpdateTransaction(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds the repository with a base transaction and returns its id.
    private func seedTransaction(totalAmount: Decimal = 30) async throws -> UUID {
        let id = UUID()
        let split = await TransactionSplit(transactionId: id, accountId: UUID(), amount: totalAmount)
        let transaction = await Transaction(
            id: id,
            label: "Initial",
            date: Date(),
            totalAmount: totalAmount,
            isExpense: true,
            type: .other,
            splits: [split]
        )
        try await repository.save(transaction)
        return id
    }

    // MARK: Success
    /// Verifies that updating a valid transaction calls update on the repository.
    func test_execute_validInput_callsUpdate() async throws {
        let id = try await seedTransaction()
        let split = await TransactionSplit(transactionId: id, accountId: UUID(), amount: 50)
        try await useCase.execute(
            id: id,
            label: "Updated label",
            date: Date(),
            totalAmount: 50,
            isExpense: false,
            type: .salary,
            splits: [split]
        )
        XCTAssertTrue(repository.didCallUpdate)
    }

    /// Verifies that removing a split and adjusting amounts succeeds when rules are respected.
    func test_execute_removeSplit_succeeds() async throws {
        let id = try await seedTransaction(totalAmount: 30)
        let split = await TransactionSplit(transactionId: id, accountId: UUID(), amount: 30)
        try await useCase.execute(
            id: id,
            label: "Updated",
            date: Date(),
            totalAmount: 30,
            isExpense: true,
            type: .restaurant,
            splits: [split]
        )
        XCTAssertTrue(repository.didCallUpdate)
    }

    // MARK: Validation

    /// Verifies that updating with an empty label throws emptyLabel.
    func test_execute_emptyLabel_throwsEmptyLabel() async throws {
        let id = try await seedTransaction()
        let split = await TransactionSplit(transactionId: id, accountId: UUID(), amount: 30)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, label: "", date: Date(), totalAmount: 30, isExpense: true, type: .other, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyLabel)
        }
    }
    
    /// Verifies that a zero totalAmount throws invalidTotalAmount.
       func test_execute_zeroTotalAmount_throwsInvalidTotalAmount() async throws {
           let id = try await seedTransaction()
           let split = await TransactionSplit(transactionId: id, accountId: UUID(), amount: 30)
           await XCTAssertThrowsErrorAsync(
               try await useCase.execute(id: id, label: "Test", date: Date(), totalAmount: 0, isExpense: true, type: .other, splits: [split])
           ) { error in
               XCTAssertEqual(error as? TransactionError, .invalidTotalAmount)
           }
       }

    /// Verifies that removing all splits throws missingSplits.
    func test_execute_emptySplits_throwsMissingSplits() async throws {
        let id = try await seedTransaction()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, label: "Test", date: Date(), totalAmount: 30, isExpense: true, type: .other, splits: [])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .missingSplits)
        }
    }
    
    /// Verifies that a split with zero amount throws invalidSplitAmount.
    func test_execute_zeroSplitAmount_throwsInvalidSplitAmount() async throws {
        let id = try await seedTransaction()
        let split = await TransactionSplit(transactionId: id, accountId: UUID(), amount: 0)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, label: "Test", date: Date(), totalAmount: 30, isExpense: true, type: .other, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidSplitAmount)
        }
    }

    /// Verifies that mismatched split amounts throw splitAmountMismatch.
    func test_execute_splitMismatch_throwsSplitAmountMismatch() async throws {
        let id = try await seedTransaction()
        let split = await TransactionSplit(transactionId: id, accountId: UUID(), amount: 10)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, label: "Test", date: Date(), totalAmount: 30, isExpense: true, type: .other, splits: [split])
        ) { error in
            XCTAssertEqual(error as? TransactionError, .splitAmountMismatch)
        }
    }
}
