//
//  TransferDetailViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation
import Toasty

/// Manages the data and actions for the transfer detail screen.
@MainActor
@Observable
final class TransferDetailViewModel {

    // MARK: State

    private(set) var expense: Transaction
    private(set) var income: Transaction
    var sourceName: String = ""
    var destinationName: String = ""
    var isLoading = false
    var isDeleted = false
    var showDeleteAlert = false

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let deleteTransfer: DeleteTransfer
    private let getAccount: GetAccount

    // MARK: Init

    /// - Parameters:
    ///   - expense: The expense leg of the transfer (source account).
    ///   - income: The income leg of the transfer (destination account).
    ///   - toasty: Toaster to display messages to the user.
    ///   - deleteTransfer: UseCase for deleting both transfer legs.
    ///   - getAccount: UseCase for resolving account names from split identifiers.
    init(
        expense: Transaction,
        income: Transaction,
        toasty: ToastyManager,
        deleteTransfer: DeleteTransfer,
        getAccount: GetAccount
    ) {
        self.expense = expense
        self.income = income
        self.toasty = toasty
        self.deleteTransfer = deleteTransfer
        self.getAccount = getAccount
    }

    // MARK: Actions

    /// Resolves the source and destination account names from the split identifiers.
    func load() async {
        isLoading = true
        if let sourceId = expense.splits.first?.accountId,
           let account = try? await getAccount.execute(id: sourceId) {
            sourceName = account.name
        }
        if let destId = income.splits.first?.accountId,
           let account = try? await getAccount.execute(id: destId) {
            destinationName = account.name
        }
        isLoading = false
    }

    /// Deletes both legs of the transfer and signals the view to dismiss.
    func delete() async {
        do {
            try await deleteTransfer.execute(expenseId: expense.id, incomeId: income.id)
            isDeleted = true
        } catch {
            toasty.showError(error)
        }
    }
}
