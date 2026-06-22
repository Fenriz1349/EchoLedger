//
//  DeleteInstitutionRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteInstitutionRuleTests: XCTestCase {

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var transactionRepository: TransactionDouble!
    private var rule: DeleteInstitutionRule!
    private let userId = UUID()
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        transactionRepository = TransactionDouble()
        let deleteAccountRule = DeleteAccountRule(
            getTransactionsByAccount: GetTransactionsByAccount(getTransactions: GetTransactions(repository: transactionRepository)),
            deleteTransaction: DeleteTransaction(repository: transactionRepository, deleteDocument: DocumentDeletingDouble()),
            updateTransaction: UpdateTransaction(repository: transactionRepository),
            deleteAccount: DeleteAccount(repository: accountRepository),
            userId: userId
        )
        rule = DeleteInstitutionRule(
            getAccounts: GetAccounts(repository: accountRepository),
            deleteAccountRule: deleteAccountRule,
            deleteInstitution: DeleteInstitution(repository: institutionRepository)
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        transactionRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an institution with one account and one transaction on that account; returns their ids.
    @discardableResult
    private func seedTree() async throws -> (accountId: UUID, transactionId: UUID) {
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId))
        let accountId = UUID()
        try await accountRepository.save(TestData.account(id: accountId, institutionId: institutionId))
        let transactionId = UUID()
        let transaction = Transaction(id: transactionId, userId: userId, label: "T", date: Date(),
                                      totalAmount: 30, isExpense: true, category: .other,
                                      splits: [TransactionSplit(accountId: accountId, amount: 30)])
        try await transactionRepository.save(transaction)
        return (accountId, transactionId)
    }

    // MARK: Tests
    /// Verifies that the institution record is deleted.
    func test_execute_deletesInstitution() async throws {
        try await seedTree()
        try await rule.execute(id: institutionId)
        await XCTAssertThrowsErrorAsync(
            try await institutionRepository.fetch(by: institutionId)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }

    /// Verifies that the institution's accounts are deleted in cascade.
    func test_execute_deletesLinkedAccounts() async throws {
        let (accountId, _) = try await seedTree()
        try await rule.execute(id: institutionId)
        await XCTAssertThrowsErrorAsync(
            try await accountRepository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
    }

    /// Verifies that the transactions of those accounts are deleted in cascade.
    func test_execute_deletesLinkedTransactions() async throws {
        let (_, transactionId) = try await seedTree()
        try await rule.execute(id: institutionId)
        await XCTAssertThrowsErrorAsync(
            try await transactionRepository.fetch(by: transactionId)
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }
}
