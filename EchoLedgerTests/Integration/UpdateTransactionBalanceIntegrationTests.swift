//
//  UpdateTransactionBalanceIntegrationTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
@testable import EchoLedger

/// Chains AddTransaction, UpdateTransaction and GetAccountBalance against shared in-memory
/// repositories to verify editing a transaction's splits is correctly reflected in the balance.
@MainActor
final class UpdateTransactionBalanceIntegrationTests: XCTestCase {

    private var accountRepository: AccountDouble!
    private var transactionRepository: TransactionDouble!
    private var addTransaction: AddTransaction!
    private var updateTransaction: UpdateTransaction!
    private var getAccountBalance: GetAccountBalance!
    private let userId = UUID()
    private let accountId = UUID()

    override func setUp() {
        super.setUp()
        accountRepository = AccountDouble()
        transactionRepository = TransactionDouble()
        addTransaction = AddTransaction(repository: transactionRepository)
        updateTransaction = UpdateTransaction(repository: transactionRepository)
        getAccountBalance = GetAccountBalance(
            accountRepository: accountRepository,
            transactionRepository: transactionRepository
        )
    }

    override func tearDown() {
        accountRepository = nil
        transactionRepository = nil
        addTransaction = nil
        updateTransaction = nil
        getAccountBalance = nil
        super.tearDown()
    }

    /// Verifies that editing a transaction's total/splits recomputes the account's balance.
    func test_updateTransaction_recomputesAccountBalance() async throws {
        try await accountRepository.save(TestData.account(id: accountId, name: "Compte courant"))

        let created = try await addTransaction.execute(AddTransactionInput(
            userId: userId,
            label: "Courses",
            date: Date(),
            totalAmount: 100,
            note: nil,
            isExpense: true,
            category: .shopping,
            splits: [TransactionSplit(accountId: accountId, amount: 100)]
        ))
        let initialBalance = try await getAccountBalance.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(initialBalance, -100)

        try await updateTransaction.execute(UpdateTransactionInput(
            id: created.id,
            userId: userId,
            label: "Courses",
            date: Date(),
            totalAmount: 40,
            note: nil,
            isExpense: true,
            category: .shopping,
            splits: [TransactionSplit(accountId: accountId, amount: 40)]
        ))
        let updatedBalance = try await getAccountBalance.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(updatedBalance, -40)
    }
}
