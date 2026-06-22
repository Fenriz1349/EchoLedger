//
//  DeleteAccountRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteAccountRuleTests: XCTestCase {

    private var transactionRepository: TransactionDouble!
    private var accountRepository: AccountDouble!
    private var rule: DeleteAccountRule!
    private let userId = UUID()
    private let accountId = UUID()

    override func setUp() {
        super.setUp()
        transactionRepository = TransactionDouble()
        accountRepository = AccountDouble()
        rule = DeleteAccountRule(
            getTransactionsByAccount: GetTransactionsByAccount(getTransactions: GetTransactions(repository: transactionRepository)),
            deleteTransaction: DeleteTransaction(repository: transactionRepository, deleteDocument: DocumentDeletingDouble()),
            updateTransaction: UpdateTransaction(repository: transactionRepository),
            deleteAccount: DeleteAccount(repository: accountRepository),
            userId: userId
        )
    }

    override func tearDown() {
        transactionRepository = nil
        accountRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func makeTransaction(id: UUID = UUID(), splits: [TransactionSplit]) -> Transaction {
        Transaction(id: id,
                    userId: userId,
                    label: "T",
                    date: Date(),
                    totalAmount: splits.map(\.amount).reduce(0, +),
                    isExpense: true,
                    category: .other,
                    splits: splits)
    }

    // MARK: Tests
    /// Verifies that the account record is deleted.
    func test_execute_deletesAccount() async throws {
        try await accountRepository.save(TestData.account(id: accountId))
        try await rule.execute(id: accountId)
        await XCTAssertThrowsErrorAsync(
            try await accountRepository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }

    /// Verifies that a transaction whose only split is on the account is fully deleted.
    func test_execute_singleAccountTransaction_isDeleted() async throws {
        let txnId = UUID()
        try await accountRepository.save(TestData.account(id: accountId))
        try await transactionRepository.save(makeTransaction(id: txnId, splits: [
            TransactionSplit(accountId: accountId, amount: 30)
        ]))
        try await rule.execute(id: accountId)
        await XCTAssertThrowsErrorAsync(
            try await transactionRepository.fetch(by: txnId)
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }

    /// Verifies that a multi-account transaction keeps its other split and recomputes the total.
    func test_execute_multiAccountTransaction_dropsSplitAndRecomputesTotal() async throws {
        let txnId = UUID()
        let otherAccountId = UUID()
        try await accountRepository.save(TestData.account(id: accountId))
        try await transactionRepository.save(makeTransaction(id: txnId, splits: [
            TransactionSplit(accountId: accountId, amount: 15),
            TransactionSplit(accountId: otherAccountId, amount: 15)
        ]))
        try await rule.execute(id: accountId)
        let updated = try await transactionRepository.fetch(by: txnId)
        XCTAssertEqual(updated.splits.count, 1)
        XCTAssertEqual(updated.totalAmount, 15)
        XCTAssertFalse(updated.belongs(to: accountId))
    }
}
