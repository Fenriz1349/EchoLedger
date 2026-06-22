//
//  TransferBetweenAccountsTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class TransferBetweenAccountsTests: XCTestCase {

    private var repository: TransactionDouble!
    private var useCase: TransferBetweenAccounts!
    private let userId = UUID()
    private let sourceAccountId = UUID()
    private let destinationAccountId = UUID()

    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = TransferBetweenAccounts(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func makeInput(amount: Double = 100, label: String = "Virement") -> TransferFormInput {
        TransferFormInput(
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            amount: amount,
            date: Date(),
            label: label,
            userId: userId
        )
    }

    // MARK: Tests
    /// Verifies that a transfer creates two transactions.
    func test_execute_createsBothLegs() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: userId)
        XCTAssertEqual(transactions.count, 2)
    }

    /// Verifies that the expense leg debits the source account and is tagged as a transfer.
    func test_execute_createsExpenseLegOnSource() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: userId)
        let expense = transactions.first { $0.isExpense }
        XCTAssertEqual(expense?.category, .transfer)
        XCTAssertTrue(expense?.belongs(to: sourceAccountId) ?? false)
    }

    /// Verifies that the income leg credits the destination account and is tagged as a transfer.
    func test_execute_createsIncomeLegOnDestination() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: userId)
        let income = transactions.first { !$0.isExpense }
        XCTAssertEqual(income?.category, .transfer)
        XCTAssertTrue(income?.belongs(to: destinationAccountId) ?? false)
    }
}
