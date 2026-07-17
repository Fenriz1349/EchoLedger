//
//  AccountRecencySorterTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
@testable import EchoLedger

final class AccountRecencySorterTests: XCTestCase {

    // MARK: Helpers
    /// Builds a single-split transaction on the given account, dated as given.
    private func transaction(on accountId: UUID, date: Date) -> Transaction {
        Transaction(userId: UUID(),
                   label: "Test",
                   date: date,
                   totalAmount: 30,
                   isExpense: true,
                   category: .other,
                   splits: [TransactionSplit(accountId: accountId, amount: 30)])
    }

    // MARK: Tests
    /// Verifies that the account used most recently comes first.
    func test_sort_ordersByMostRecentUseFirst() {
        let older = TestData.account(name: "Older")
        let recent = TestData.account(name: "Recent")
        let items = [
            AccountDisplayItem(account: older, institutionName: "Bank"),
            AccountDisplayItem(account: recent, institutionName: "Bank")
        ]
        let transactions = [
            transaction(on: older.id, date: Date().addingTimeInterval(-3600)),
            transaction(on: recent.id, date: Date())
        ]

        let result = AccountRecencySorter.sort(items, using: transactions)

        XCTAssertEqual(result.map(\.account.name), ["Recent", "Older"])
    }

    /// Verifies that a never-used account sinks below every used account.
    func test_sort_neverUsedAccountSinksBelowUsedOnes() {
        let used = TestData.account(name: "Used")
        let neverUsed = TestData.account(name: "Alpha")
        let items = [
            AccountDisplayItem(account: neverUsed, institutionName: "Bank"),
            AccountDisplayItem(account: used, institutionName: "Bank")
        ]
        let transactions = [transaction(on: used.id, date: Date())]

        let result = AccountRecencySorter.sort(items, using: transactions)

        XCTAssertEqual(result.map(\.account.name), ["Used", "Alpha"])
    }

    /// Verifies that with no transactions at all, accounts fall back to alphabetical order.
    func test_sort_noTransactions_fallsBackToAlphabetical() {
        let zeta = TestData.account(name: "Zeta")
        let alpha = TestData.account(name: "Alpha")
        let items = [
            AccountDisplayItem(account: zeta, institutionName: "Bank"),
            AccountDisplayItem(account: alpha, institutionName: "Bank")
        ]

        let result = AccountRecencySorter.sort(items, using: [])

        XCTAssertEqual(result.map(\.account.name), ["Alpha", "Zeta"])
    }

    /// Verifies that only the latest of several transactions on the same account determines its rank.
    func test_sort_usesMostRecentTransactionPerAccount() {
        let account = TestData.account(name: "Solo")
        let other = TestData.account(name: "Other")
        let items = [
            AccountDisplayItem(account: other, institutionName: "Bank"),
            AccountDisplayItem(account: account, institutionName: "Bank")
        ]
        let transactions = [
            transaction(on: account.id, date: Date().addingTimeInterval(-7200)),
            transaction(on: other.id, date: Date().addingTimeInterval(-3600)),
            transaction(on: account.id, date: Date())
        ]

        let result = AccountRecencySorter.sort(items, using: transactions)

        XCTAssertEqual(result.map(\.account.name), ["Solo", "Other"])
    }
}
