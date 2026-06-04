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
    var recentItems: [TransactionListItem] = []
    var accountNames: [UUID: String] = [:]
    var expenseChartData: [(category: TransactionCategory, total: Double)] = []
    var incomeChartData: [(category: TransactionCategory, total: Double)] = []
    var isLoading = false
    var showArchiveAlert = false
    var onNotFound: (() -> Void)?

    /// Current version of the account, updated after archive/unarchive.
    private(set) var account: Account

    var isArchived: Bool { account.isArchived }

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let getTransactions: GetTransactions
    private let getAccountBalance: GetAccountBalance
    private let getAccount: GetAccount
    private let archiveAccount: ArchiveAccount
    private let unarchiveAccount: UnarchiveAccount
    private let deleteTransaction: DeleteTransaction
    private let deleteTransferUseCase: DeleteTransfer
    private let userId: UUID

    // MARK: Init

    /// - Parameters:
    ///   - account: The account to display.
    ///   - toasty: Toaster to display messages to the user.
    ///   - getTransactions: UseCase for fetching all user transactions.
    ///   - getAccountBalance: UseCase for computing the account balance.
    ///   - getAccount: UseCase for resolving account names (used for transfer rows).
    ///   - archiveAccount: UseCase for archiving the account.
    ///   - unarchiveAccount: UseCase for restoring the account.
    ///   - deleteTransaction: UseCase for deleting a transaction.
    ///   - deleteTransfer: UseCase for deleting both legs of a transfer.
    ///   - userId: The identifier of the current user.
    init(
        account: Account,
        toasty: ToastyManager,
        getTransactions: GetTransactions,
        getAccountBalance: GetAccountBalance,
        getAccount: GetAccount,
        archiveAccount: ArchiveAccount,
        unarchiveAccount: UnarchiveAccount,
        deleteTransaction: DeleteTransaction,
        deleteTransfer: DeleteTransfer,
        userId: UUID
    ) {
        self.account = account
        self.toasty = toasty
        self.getTransactions = getTransactions
        self.getAccountBalance = getAccountBalance
        self.getAccount = getAccount
        self.archiveAccount = archiveAccount
        self.unarchiveAccount = unarchiveAccount
        self.deleteTransaction = deleteTransaction
        self.deleteTransferUseCase = deleteTransfer
        self.userId = userId
    }

    // MARK: Actions

    /// Loads balance, recent transactions and chart data for this account.
    func load() async {
        isLoading = true
        do {
            // Verify the account still exists before loading its data
            _ = try await getAccount.execute(id: account.id)

            async let balanceResult = getAccountBalance.execute(accountId: account.id, userId: userId)
            async let transactionsResult = getTransactions.execute(for: userId)

            let (fetchedBalance, allTransactions) = try await (balanceResult, transactionsResult)

            balance = fetchedBalance

            let accountTransactions = allTransactions
                .filter { $0.splits.contains { $0.accountId == account.id } }
                .sorted { $0.date > $1.date }

            expenseChartData = chartData(from: accountTransactions.filter { $0.isExpense && $0.category.isReportable })
            incomeChartData = chartData(from: accountTransactions.filter { !$0.isExpense && $0.category.isReportable })

            // Group all transactions so transfer pairs are merged before filtering by account.
            // Filtering account-only transactions before grouping would break pairing.
            recentItems = TransactionListItem.group(allTransactions)
                .filter { item in
                    switch item {
                    case .single(let transaction):
                        return transaction.splits.contains { $0.accountId == account.id }
                    case .transfer(let transfer):
                        return transfer.source.splits.contains { $0.accountId == account.id }
                            || transfer.destination.splits.contains { $0.accountId == account.id }
                    }
                }
                .prefix(10)
                .map { $0 }

            for item in recentItems {
                if case .transfer(let transfer) = item {
                    for split in (transfer.source.splits + transfer.destination.splits) {
                        guard accountNames[split.accountId] == nil else { continue }
                        if let resolved = try? await getAccount.execute(id: split.accountId) {
                            accountNames[split.accountId] = resolved.name
                        }
                    }
                }
            }
        } catch is AccountError {
            onNotFound?()
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

    /// Deletes both legs of an internal transfer and reloads the data.
    func deleteTransfer(_ transfer: Transfer) async {
        do {
            try await deleteTransferUseCase.execute(transfer)
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
