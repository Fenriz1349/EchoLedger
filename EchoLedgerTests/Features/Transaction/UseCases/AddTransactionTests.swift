//
//  AddTransactionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class AddTransactionTests: XCTestCase {

    private var repository: TransactionDouble!
    private var useCase: AddTransaction!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = AddTransaction(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Returns a valid AddTransactionInput with sensible defaults.
    private func makeInput(
        label: String = "Restaurant",
        totalAmount: Double = 30,
        isExpense: Bool = true,
        category: TransactionCategory = .restaurant,
        splits: [TransactionSplit]? = nil
    ) -> AddTransactionInput {
        let defaultSplits = splits ?? [TransactionSplit(accountId: UUID(), amount: totalAmount)]
        return AddTransactionInput(
            userId: userId,
            label: label,
            date: Date(),
            totalAmount: totalAmount,
            note: nil,
            isExpense: isExpense,
            category: category,
            splits: defaultSplits
        )
    }

    // MARK: Success
    /// Verifies that a valid transaction is persisted to the repository.
    func test_execute_validInput_savesTransaction() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: userId)
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.label, "Restaurant")
    }

    /// Verifies that multiple splits summing to totalAmount are persisted.
    func test_execute_multipleSplits_sumMatchesTotalAmount_succeeds() async throws {
        let splits = [
            TransactionSplit(accountId: UUID(), amount: 15),
            TransactionSplit(accountId: UUID(), amount: 15)
        ]
        try await useCase.execute(makeInput(totalAmount: 30, splits: splits))
        let transactions = try await repository.fetchAll(for: userId)
        XCTAssertEqual(transactions.first?.splits.count, 2)
    }

    // MARK: Label Validation
    /// Verifies that an empty label throws emptyLabel.
    func test_execute_emptyLabel_throwsEmptyLabel() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(label: ""))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyLabel)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "Le libellé de la transaction ne peut pas être vide.")
        }
    }

    /// Verifies that a whitespace-only label throws emptyLabel.
    func test_execute_whitespaceLabel_throwsEmptyLabel() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(label: "   "))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyLabel)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "Le libellé de la transaction ne peut pas être vide.")
        }
    }

    // MARK: Amount Validation
    /// Verifies that a zero totalAmount throws invalidTotalAmount.
    func test_execute_zeroTotalAmount_throwsInvalidTotalAmount() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(totalAmount: 0,
                                                splits: [TransactionSplit(accountId: UUID(), amount: 0)]))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidTotalAmount)
            XCTAssertEqual((error as? TransactionError)?.errorDescription, "Le montant total doit être positif.")
        }
    }

    /// Verifies that a negative totalAmount throws invalidTotalAmount.
    func test_execute_negativeTotalAmount_throwsInvalidTotalAmount() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(totalAmount: -10,
                                                splits: [TransactionSplit(accountId: UUID(), amount: 10)]))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidTotalAmount)
            XCTAssertEqual((error as? TransactionError)?.errorDescription, "Le montant total doit être positif.")
        }
    }

    // MARK: Split Validation
    /// Verifies that an empty splits array throws missingSplits.
    func test_execute_emptySplits_throwsMissingSplits() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(splits: []))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .missingSplits)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "Une transaction doit avoir au moins une ventilation.")
        }
    }

    /// Verifies that a split with a zero amount throws invalidSplitAmount.
    func test_execute_zeroSplitAmount_throwsInvalidSplitAmount() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(splits: [TransactionSplit(accountId: UUID(), amount: 0)]))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidSplitAmount)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "Le montant d'une ventilation doit être positif.")
        }
    }

    /// Verifies that splits not summing to totalAmount throws splitAmountMismatch.
    func test_execute_splitMismatch_throwsSplitAmountMismatch() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(totalAmount: 30,
                                                splits: [TransactionSplit(accountId: UUID(), amount: 20)]))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .splitAmountMismatch)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "La somme des ventilations ne correspond pas au montant total.")
        }
    }
}
