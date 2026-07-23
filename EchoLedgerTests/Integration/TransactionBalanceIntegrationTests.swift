//
//  TransactionBalanceIntegrationTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
@testable import EchoLedger

/// Chains AddAccount, AddTransaction and GetAccountBalance against shared in-memory repositories
/// (no SwiftData, no Firebase) to verify these use cases integrate correctly with one another.
@MainActor
final class TransactionBalanceIntegrationTests: XCTestCase {

    private var accountRepository: AccountDouble!
    private var transactionRepository: TransactionDouble!
    private var addAccount: AddAccount!
    private var addTransaction: AddTransaction!
    private var getAccountBalance: GetAccountBalance!
    private let userId = UUID()
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        accountRepository = AccountDouble()
        transactionRepository = TransactionDouble()
        addAccount = AddAccount(repository: accountRepository)
        addTransaction = AddTransaction(repository: transactionRepository)
        getAccountBalance = GetAccountBalance(
            accountRepository: accountRepository,
            transactionRepository: transactionRepository
        )
    }

    override func tearDown() {
        accountRepository = nil
        transactionRepository = nil
        addAccount = nil
        addTransaction = nil
        getAccountBalance = nil
        super.tearDown()
    }

    /// Verifies that a transaction added on a freshly created account is reflected in its balance.
    func test_addAccountThenAddTransaction_reflectsInBalance() async throws {
        try await addAccount.execute(institutionId: institutionId, name: "Compte courant", category: .checking)
        let accounts = try await accountRepository.fetchAll(for: institutionId)
        let accountId = try XCTUnwrap(accounts.first?.id)

        let input = AddTransactionInput(
            userId: userId,
            label: "Salaire",
            date: Date(),
            totalAmount: 2000,
            note: nil,
            isExpense: false,
            category: .salary,
            splits: [TransactionSplit(accountId: accountId, amount: 2000)]
        )
        try await addTransaction.execute(input)

        let balance = try await getAccountBalance.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(balance, 2000)
    }
}
