//
//  UpdateTransactionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UpdateTransactionTests: XCTestCase {

    private var repository: TransactionDouble!
    private var useCase: UpdateTransaction!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = UpdateTransaction(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds the repository with a base transaction and returns its id.
    func seedTransaction(totalAmount: Double = 30) async throws -> UUID {
        let split = TransactionSplit(accountId: UUID(), amount: totalAmount)
        let transaction = Transaction(userId: userId,
                                      label: "Initial",
                                      date: Date(),
                                      totalAmount: totalAmount,
                                      isExpense: true,
                                      category: .other,
                                      splits: [split])
        try await repository.save(transaction)
        return transaction.id
    }

    /// Returns a valid UpdateTransactionInput with sensible defaults.
    private func makeInput(
        id: UUID,
        label: String = "Updated",
        totalAmount: Double = 30,
        isExpense: Bool = true,
        category: TransactionCategory = .other,
        splits: [TransactionSplit]? = nil
    ) -> UpdateTransactionInput {
        let defaultSplits = splits ?? [TransactionSplit(accountId: UUID(), amount: totalAmount)]
        return UpdateTransactionInput(
            id: id,
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
    /// Verifies that a valid update persists the new values.
    func test_execute_validInput_updatesTransaction() async throws {
        let id = try await seedTransaction()
        try await useCase.execute(makeInput(id: id, totalAmount: 50))
        let updated = try await repository.fetch(by: id)
        XCTAssertEqual(updated.totalAmount, 50)
    }

    /// Verifies that updating with multiple splits summing to the total persists them.
    func test_execute_multipleSplits_succeeds() async throws {
        let id = try await seedTransaction()
        let splits = [
            TransactionSplit(accountId: UUID(), amount: 15),
            TransactionSplit(accountId: UUID(), amount: 15)
        ]
        try await useCase.execute(makeInput(id: id, totalAmount: 30, splits: splits))
        let updated = try await repository.fetch(by: id)
        XCTAssertEqual(updated.splits.count, 2)
    }

    // MARK: Validation
    /// Verifies that updating with an empty label throws emptyLabel.
    func test_execute_emptyLabel_throwsEmptyLabel() async throws {
        let id = try await seedTransaction()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, label: ""))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .emptyLabel)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "Le libellé de la transaction ne peut pas être vide.")
        }
    }

    /// Verifies that a zero totalAmount throws invalidTotalAmount.
    func test_execute_zeroTotalAmount_throwsInvalidTotalAmount() async throws {
        let id = try await seedTransaction()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id,
                                                totalAmount: 0,
                                                splits: [TransactionSplit(accountId: UUID(), amount: 0)]))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidTotalAmount)
            XCTAssertEqual((error as? TransactionError)?.errorDescription, "Le montant total doit être positif.")
        }
    }

    /// Verifies that removing all splits throws missingSplits.
    func test_execute_emptySplits_throwsMissingSplits() async throws {
        let id = try await seedTransaction()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, splits: []))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .missingSplits)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "Une transaction doit avoir au moins une ventilation.")
        }
    }

    /// Verifies that a split with zero amount throws invalidSplitAmount.
    func test_execute_zeroSplitAmount_throwsInvalidSplitAmount() async throws {
        let id = try await seedTransaction()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id,
                                                splits: [TransactionSplit(accountId: UUID(), amount: 0)]))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidSplitAmount)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "Le montant d'une ventilation doit être positif.")
        }
    }

    /// Verifies that mismatched split amounts throw splitAmountMismatch.
    func test_execute_splitMismatch_throwsSplitAmountMismatch() async throws {
        let id = try await seedTransaction()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id,
                                                totalAmount: 30,
                                                splits: [TransactionSplit(accountId: UUID(), amount: 10)]))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .splitAmountMismatch)
            XCTAssertEqual((error as? TransactionError)?.errorDescription,
                          "La somme des ventilations ne correspond pas au montant total.")
        }
    }
}
