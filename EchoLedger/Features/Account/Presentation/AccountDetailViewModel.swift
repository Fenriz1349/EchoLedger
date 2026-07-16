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
/// Chart state lives in `graphsViewModel`, scoped to this account.
@MainActor
@Observable
final class AccountDetailViewModel {

    // MARK: State

    var recentItems: [TransactionListItem] = []
    /// The account's initial balance transaction, surfaced so the detail can offer to edit it.
    var initialBalanceTransaction: Transaction?
    var accountNames: [UUID: String] = [:]
    var showArchiveAlert = false
    var onNotFound: (() -> Void)?

    /// Current version of the account, updated after archive/unarchive.
    private(set) var account: Account

    var isArchived: Bool { account.isArchived }

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let getTransactions: GetTransactions
    private let getAccount: GetAccount
    private let archiveAccount: ArchiveAccount
    private let unarchiveAccount: UnarchiveAccountRule
    private let deleteTransaction: DeleteTransaction
    private let deleteTransferUseCase: DeleteTransfer
    private let userId: UUID
    let graphsViewModel: GraphsViewModel

    // MARK: Init

    /// - Parameters:
    ///   - account: The account to display.
    ///   - toasty: Toaster to display messages to the user.
    ///   - graphsViewModel: Child VM owning all chart state scoped to this account.
    ///   - getTransactions: UseCase for fetching all user transactions.
    ///   - getAccount: UseCase for resolving account names (used for transfer rows).
    ///   - archiveAccount: UseCase for archiving the account.
    ///   - unarchiveAccount: UseCase for restoring the account.
    ///   - deleteTransaction: UseCase for deleting a transaction.
    ///   - deleteTransfer: UseCase for deleting both legs of a transfer.
    ///   - userId: The identifier of the current user.
    init(
        account: Account,
        toasty: ToastyManager,
        graphsViewModel: GraphsViewModel,
        getTransactions: GetTransactions,
        getAccount: GetAccount,
        archiveAccount: ArchiveAccount,
        unarchiveAccount: UnarchiveAccountRule,
        deleteTransaction: DeleteTransaction,
        deleteTransfer: DeleteTransfer,
        userId: UUID
    ) {
        self.account = account
        self.toasty = toasty
        self.graphsViewModel = graphsViewModel
        self.getTransactions = getTransactions
        self.getAccount = getAccount
        self.archiveAccount = archiveAccount
        self.unarchiveAccount = unarchiveAccount
        self.deleteTransaction = deleteTransaction
        self.deleteTransferUseCase = deleteTransfer
        self.userId = userId
    }

    // MARK: Actions

    /// Loads chart data and recent transactions for this account.
    func load() async {
        do {
            _ = try await getAccount.execute(id: account.id)

            try await graphsViewModel.load(scope: .account(account.id))

            let allTransactions = try await getTransactions.execute(for: userId)

            initialBalanceTransaction = allTransactions.first {
                $0.category == .initialBalance && $0.belongs(to: account.id)
            }

            recentItems = TransactionListItem.group(
                allTransactions.filter { $0.isEffective() && $0.category.isListed }
            )
                .filter { item in
                    switch item {
                    case .single(let transaction):
                        return transaction.belongs(to: account.id)
                    case .transfer(let transfer):
                        return transfer.source.belongs(to: account.id)
                            || transfer.destination.belongs(to: account.id)
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
}
