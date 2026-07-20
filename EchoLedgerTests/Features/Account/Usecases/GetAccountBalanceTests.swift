//
//  GetAccountBalanceTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class GetAccountBalanceTests: XCTestCase {

    private var accountDouble: AccountDouble!
    private var transactionDouble: TransactionDouble!
    private var useCase: GetAccountBalance!
    private let userId = UUID()
    private let accountId = UUID()

    override func setUp() {
        super.setUp()
        accountDouble = AccountDouble()
        transactionDouble = TransactionDouble()
        useCase = GetAccountBalance(
            accountRepository: accountDouble,
            transactionRepository: transactionDouble
        )
    }

    override func tearDown() {
        accountDouble = nil
        transactionDouble = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds the shared account into the account double.
    private func seedAccount() async throws {
        let account = Account(id: accountId, institutionId: UUID(), name: "Livret A", category: .savings)
        try await accountDouble.save(account)
    }

    /// Seeds a transaction with a split on the shared accountId.
    private func seedTransaction(amount: Double, isExpense: Bool, date: Date = Date()) async throws {
        let split = TransactionSplit(accountId: accountId, amount: amount)
        let transaction = Transaction(userId: userId,
                                      label: "Test",
                                      date: date,
                                      totalAmount: amount,
                                      isExpense: isExpense,
                                      category: .other,
                                      splits: [split])
        try await transactionDouble.save(transaction)
    }

    // MARK: Tests
    /// Verifies that the balance is zero when no transactions exist.
    func test_execute_noTransactions_returnsZero() async throws {
        try await seedAccount()
        let balance = try await useCase.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(balance, 0)
    }

    /// Verifies that expenses are subtracted from the balance.
    func test_execute_expenseTransaction_subtractsFromBalance() async throws {
        try await seedAccount()
        try await seedTransaction(amount: 30, isExpense: true)
        let balance = try await useCase.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(balance, -30)
    }

    /// Verifies that income is added to the balance.
    func test_execute_incomeTransaction_addsToBalance() async throws {
        try await seedAccount()
        try await seedTransaction(amount: 100, isExpense: false)
        let balance = try await useCase.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(balance, 100)
    }

    /// Verifies that mixed transactions compute the correct balance.
    func test_execute_mixedTransactions_returnsCorrectBalance() async throws {
        try await seedAccount()
        try await seedTransaction(amount: 100, isExpense: false)
        try await seedTransaction(amount: 30, isExpense: true)
        try await seedTransaction(amount: 20, isExpense: true)
        let balance = try await useCase.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(balance, 50)
    }

    /// Verifies that future-dated transactions are excluded from the balance.
    func test_execute_futureTransaction_isExcluded() async throws {
        try await seedAccount()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        try await seedTransaction(amount: 100, isExpense: false, date: tomorrow)
        let balance = try await useCase.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(balance, 0)
    }

    /// Verifies that transactions on other accounts do not affect the balance.
    func test_execute_transactionOnOtherAccount_doesNotAffectBalance() async throws {
        try await seedAccount()
        let otherSplit = TransactionSplit(accountId: UUID(), amount: 50)
        let transaction = Transaction(userId: userId,
                                      label: "Autre",
                                      date: Date(),
                                      totalAmount: 50,
                                      isExpense: true,
                                      category: .other,
                                      splits: [otherSplit])
        try await transactionDouble.save(transaction)
        let balance = try await useCase.execute(accountId: accountId, userId: userId)
        XCTAssertEqual(balance, 0)
    }

    /// Verifies that notFound is thrown when the account does not exist.
    func test_execute_unknownAccount_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(accountId: UUID(), userId: userId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
            XCTAssertEqual((error as? AccountError)?.errorDescription, "Compte introuvable.")
        }
    }
}
