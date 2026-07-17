//
//  TransferBetweenAccountsIntegrationTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
@testable import EchoLedger

/// Chains TransferBetweenAccounts, GetTransactionsByAccount and GetAccountBalance against shared
/// in-memory repositories to verify a transfer's two legs stay consistent for both accounts.
@MainActor
final class TransferBetweenAccountsIntegrationTests: XCTestCase {

    private var accountRepository: AccountDouble!
    private var transactionRepository: TransactionDouble!
    private var transferBetweenAccounts: TransferBetweenAccounts!
    private var getTransactionsByAccount: GetTransactionsByAccount!
    private var getAccountBalance: GetAccountBalance!
    private let userId = UUID()
    private let sourceAccountId = UUID()
    private let destinationAccountId = UUID()

    override func setUp() {
        super.setUp()
        accountRepository = AccountDouble()
        transactionRepository = TransactionDouble()
        transferBetweenAccounts = TransferBetweenAccounts(repository: transactionRepository)
        getTransactionsByAccount = GetTransactionsByAccount(
            getTransactions: GetTransactions(repository: transactionRepository)
        )
        getAccountBalance = GetAccountBalance(
            accountRepository: accountRepository,
            transactionRepository: transactionRepository
        )
    }

    override func tearDown() {
        accountRepository = nil
        transactionRepository = nil
        transferBetweenAccounts = nil
        getTransactionsByAccount = nil
        getAccountBalance = nil
        super.tearDown()
    }

    /// Verifies both legs of a transfer are visible per account and each balance reflects it.
    func test_transferBetweenAccounts_bothLegsConsistentForBothAccounts() async throws {
        try await accountRepository.save(TestData.account(id: sourceAccountId, name: "Compte courant"))
        try await accountRepository.save(TestData.account(id: destinationAccountId, name: "Livret A"))

        let input = TransferFormInput(
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            amount: 300,
            date: Date(),
            label: "Virement épargne",
            userId: userId
        )
        try await transferBetweenAccounts.execute(input)

        let sourceTransactions = try await getTransactionsByAccount.execute(for: userId, accountId: sourceAccountId)
        let destinationTransactions = try await getTransactionsByAccount.execute(
            for: userId, accountId: destinationAccountId
        )
        XCTAssertEqual(sourceTransactions.count, 1)
        XCTAssertEqual(destinationTransactions.count, 1)

        let sourceBalance = try await getAccountBalance.execute(accountId: sourceAccountId, userId: userId)
        let destinationBalance = try await getAccountBalance.execute(accountId: destinationAccountId, userId: userId)
        XCTAssertEqual(sourceBalance, -300)
        XCTAssertEqual(destinationBalance, 300)
    }
}
