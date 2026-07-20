//
//  GetChartDataTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class GetChartDataTests: XCTestCase {

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var transactionRepository: TransactionDouble!
    private var useCase: GetChartData!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        transactionRepository = TransactionDouble()
        useCase = GetChartData(
            getInstitutions: GetInstitutions(repository: institutionRepository),
            getAccounts: GetAccounts(repository: accountRepository),
            getTransactions: GetTransactions(repository: transactionRepository),
            userId: userId
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        transactionRepository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func seedInstitution(id: UUID) async throws {
        try await institutionRepository.save(TestData.institution(id: id, userId: userId))
    }

    private func seedAccount(id: UUID, institutionId: UUID, isArchived: Bool = false) async throws {
        try await accountRepository.save(TestData.account(id: id, institutionId: institutionId, isArchived: isArchived))
    }

    private func seedTransaction(amount: Double, isExpense: Bool, accountId: UUID, date: Date = Date()) async throws {
        let transaction = Transaction(userId: userId, label: "T", date: date,
                                      totalAmount: amount, isExpense: isExpense, category: .other,
                                      splits: [TransactionSplit(accountId: accountId, amount: amount)])
        try await transactionRepository.save(transaction)
    }

    // MARK: Tests
    /// Verifies that the global scope aggregates active accounts across every institution.
    func test_execute_global_aggregatesAccountsAcrossInstitutions() async throws {
        let inst1 = UUID(), acc1 = UUID()
        let inst2 = UUID(), acc2 = UUID()
        try await seedInstitution(id: inst1)
        try await seedAccount(id: acc1, institutionId: inst1)
        try await seedInstitution(id: inst2)
        try await seedAccount(id: acc2, institutionId: inst2)
        let bundle = try await useCase.execute(scope: .global)
        XCTAssertEqual(Set(bundle.accountBalances.map { $0.account.id }), [acc1, acc2])
    }

    /// Verifies that archived accounts are excluded.
    func test_execute_excludesArchivedAccounts() async throws {
        let inst = UUID(), active = UUID(), archived = UUID()
        try await seedInstitution(id: inst)
        try await seedAccount(id: active, institutionId: inst)
        try await seedAccount(id: archived, institutionId: inst, isArchived: true)
        let bundle = try await useCase.execute(scope: .global)
        XCTAssertEqual(bundle.accountBalances.map { $0.account.id }, [active])
    }

    /// Verifies that future-dated transactions are excluded from the balances.
    func test_execute_excludesFutureTransactions() async throws {
        let inst = UUID(), acc = UUID()
        try await seedInstitution(id: inst)
        try await seedAccount(id: acc, institutionId: inst)
        try await seedTransaction(amount: 100, isExpense: false, accountId: acc)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        try await seedTransaction(amount: 50, isExpense: false, accountId: acc, date: tomorrow)
        let bundle = try await useCase.execute(scope: .global)
        XCTAssertEqual(bundle.accountBalances.first?.balance, 100)
    }

    /// Verifies that the account scope narrows the result to a single account.
    func test_execute_accountScope_narrowsToSingleAccount() async throws {
        let inst = UUID(), acc1 = UUID(), acc2 = UUID()
        try await seedInstitution(id: inst)
        try await seedAccount(id: acc1, institutionId: inst)
        try await seedAccount(id: acc2, institutionId: inst)
        let bundle = try await useCase.execute(scope: .account(acc1))
        XCTAssertEqual(bundle.accountBalances.map { $0.account.id }, [acc1])
    }

    /// Verifies that the total balance is the sum of the account balances.
    func test_execute_totalBalance_sumsAccountBalances() async throws {
        let inst = UUID(), acc1 = UUID(), acc2 = UUID()
        try await seedInstitution(id: inst)
        try await seedAccount(id: acc1, institutionId: inst)
        try await seedAccount(id: acc2, institutionId: inst)
        try await seedTransaction(amount: 100, isExpense: false, accountId: acc1)
        try await seedTransaction(amount: 30, isExpense: false, accountId: acc2)
        let bundle = try await useCase.execute(scope: .global)
        XCTAssertEqual(bundle.totalBalance, 130)
    }
}
