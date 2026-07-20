//
//  DeleteTransferTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteTransferTests: XCTestCase {

    private var repository: TransactionDouble!
    private var useCase: DeleteTransfer!
    private let userId = UUID()
    private let sourceId = UUID()
    private let destinationId = UUID()

    override func setUp() {
        super.setUp()
        repository = TransactionDouble()
        useCase = DeleteTransfer(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func makeLeg(id: UUID, isExpense: Bool) -> Transaction {
        Transaction(id: id,
                    userId: userId,
                    label: "Transfer",
                    date: Date(),
                    totalAmount: 100,
                    isExpense: isExpense,
                    category: .transfer,
                    splits: [TransactionSplit(accountId: UUID(), amount: 100)])
    }

    private func makeTransfer() -> Transfer {
        Transfer(source: makeLeg(id: sourceId, isExpense: true),
                 destination: makeLeg(id: destinationId, isExpense: false))
    }

    // MARK: Tests
    /// Verifies that both legs of the transfer are deleted.
    func test_execute_deletesBothLegs() async throws {
        let transfer = makeTransfer()
        try await repository.save(transfer.source)
        try await repository.save(transfer.destination)
        try await useCase.execute(transfer)
        let remaining = try await repository.fetchAll(for: userId)
        XCTAssertTrue(remaining.isEmpty)
    }

    /// Verifies that deleting a transfer whose legs don't exist throws notFound.
    func test_execute_unknownTransfer_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeTransfer())
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
            XCTAssertEqual((error as? TransactionError)?.errorDescription, "Transaction introuvable.")
        }
    }
}
