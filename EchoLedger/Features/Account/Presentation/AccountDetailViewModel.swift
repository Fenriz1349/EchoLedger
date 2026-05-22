//
//  AccountDetailViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import Foundation
import Toasty

/// Manages the data displayed on the account detail screen:
/// balance, recent transactions, chart data, and archive/unarchive actions.
@MainActor
@Observable
final class AccountDetailViewModel {

    // MARK: State

    var balance: Double = 0
    var recentTransactions: [Transaction] = []
    var expenseChartData: [(category: TransactionCategory, total: Double)] = []
    var incomeChartData: [(category: TransactionCategory, total: Double)] = []
    var isLoading = false
    var showArchiveAlert = false

    /// Current version of the account, updated after archive/unarchive.
    private(set) var account: Account

    var isArchived: Bool { account.isArchived }

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let getTransactions: GetTransactions
    private let getAccountBalance: GetAccountBalance
    private let archiveAccount: ArchiveAccount
    private let unarchiveAccount: UnarchiveAccount
    private let deleteTransaction: DeleteTransaction
    private let userId: UUID

    // MARK: Init

    /// - Parameters:
    ///   - account: The account to display.
    ///   - toasty: Toaster to display messages to the user.
    ///   - getTransactions: UseCase for fetching all user transactions.
    ///   - getAccountBalance: UseCase for computing the account balance.
    ///   - archiveAccount: UseCase for archiving the account.
    ///   - unarchiveAccount: UseCase for restoring the account.
    ///   - deleteTransaction: UseCase for deleting a transaction.
    ///   - userId: The identifier of the current user.
    init(
        account: Account,
        toasty: ToastyManager,
        getTransactions: GetTransactions,
        getAccountBalance: GetAccountBalance,
        archiveAccount: ArchiveAccount,
        unarchiveAccount: UnarchiveAccount,
        deleteTransaction: DeleteTransaction,
        userId: UUID
    ) {
        self.account = account
        self.toasty = toasty
        self.getTransactions = getTransactions
        self.getAccountBalance = getAccountBalance
        self.archiveAccount = archiveAccount
        self.unarchiveAccount = unarchiveAccount
        self.deleteTransaction = deleteTransaction
        self.userId = userId
    }

    // MARK: Actions

    /// Loads balance, recent transactions and chart data for this account.
    func load() async {
        isLoading = true
        do {
            async let balanceResult = getAccountBalance.execute(accountId: account.id, userId: userId)
            async let transactionsResult = getTransactions.execute(for: userId)

            let (fetchedBalance, allTransactions) = try await (balanceResult, transactionsResult)

            balance = fetchedBalance

            let accountTransactions = allTransactions
                .filter { $0.splits.contains { $0.accountId == account.id } }
                .sorted { $0.date > $1.date }

            recentTransactions = Array(accountTransactions.prefix(5))
            expenseChartData = chartData(from: accountTransactions.filter { $0.isExpense && $0.category.isReportable })
            incomeChartData = chartData(from: accountTransactions.filter { !$0.isExpense && $0.category.isReportable })
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Archives the account.
    func archive() async {
        do {
            try await archiveAccount.execute(id: account.id)
            account = Account(
                id: account.id,
                institutionId: account.institutionId,
                name: account.name,
                category: account.category,
                isArchived: true,
                updatedAt: Date()
            )
        } catch {
            toasty.showError(error)
        }
    }

    /// Deletes a transaction and reloads the data.
    func delete(_ transaction: Transaction) async {
        do {
            try await deleteTransaction.execute(id: transaction.id)
            await load()
        } catch {
            toasty.showError(error)
        }
    }

    /// Restores the account to active status.
    func unarchive() async {
        do {
            try await unarchiveAccount.execute(id: account.id)
            account = Account(
                id: account.id,
                institutionId: account.institutionId,
                name: account.name,
                category: account.category,
                isArchived: false,
                updatedAt: Date()
            )
        } catch {
            toasty.showError(error)
        }
    }

    // MARK: Helpers

    /// Groups transactions by category and sums amounts, sorted descending by total.
    private func chartData(from transactions: [Transaction]) -> [(category: TransactionCategory, total: Double)] {
        var totals: [TransactionCategory: Double] = [:]
        for transaction in transactions {
            let split = transaction.splits.filter { $0.accountId == account.id }.map(\.amount).reduce(0, +)
            totals[transaction.category, default: 0] += split
        }
        return totals
            .map { (category: $0.key, total: $0.value) }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }
}
