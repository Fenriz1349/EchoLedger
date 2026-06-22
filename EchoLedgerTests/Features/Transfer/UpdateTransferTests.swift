//
//  UpdateTransferTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UpdateTransferTests: XCTestCase {

    private var repository: TransactionDouble!
    private var useCase: UpdateTransfer!
    private let userId = UUID()
    private let sourceId = UUID()
    private let destinationId = UUID()
    private let sourceAccountId = UUID()
    private let destinationAccountId = UUID()

    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = UpdateTransfer(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func makeLeg(id: UUID, accountId: UUID, isExpense: Bool, amount: Double = 100) -> Transaction {
        Transaction(id: id,
                    userId: userId,
                    label: "Initial",
                    date: Date(),
                    totalAmount: amount,
                    isExpense: isExpense,
                    category: .transfer,
                    splits: [TransactionSplit(accountId: accountId, amount: amount)])
    }

    /// Seeds both legs and returns the corresponding Transfer.
    private func seedTransfer() async throws -> Transfer {
        let source = makeLeg(id: sourceId, accountId: sourceAccountId, isExpense: true)
        let destination = makeLeg(id: destinationId, accountId: destinationAccountId, isExpense: false)
        try await repository.save(source)
        try await repository.save(destination)
        return Transfer(source: source, destination: destination)
    }

    private func makeInput(amount: Double = 50, label: String = "Updated") -> TransferFormInput {
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
    /// Verifies that both legs are updated with the new values.
    func test_execute_validInput_updatesBothLegs() async throws {
        let transfer = try await seedTransfer()
        try await useCase.execute(transfer, input: makeInput(amount: 50, label: "Updated"))
        let source = try await repository.fetch(by: sourceId)
        let destination = try await repository.fetch(by: destinationId)
        XCTAssertEqual(source.totalAmount, 50)
        XCTAssertEqual(destination.totalAmount, 50)
        XCTAssertEqual(source.label, "Updated")
    }

    /// Verifies that a non-positive amount throws invalidTotalAmount.
    func test_execute_zeroAmount_throwsInvalidTotalAmount() async throws {
        let transfer = try await seedTransfer()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(transfer, input: makeInput(amount: 0))
        ) { error in
            XCTAssertEqual(error as? TransactionError, .invalidTotalAmount)
        }
    }
}
