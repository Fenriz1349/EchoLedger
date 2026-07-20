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

    let transfer: Transfer
    private(set) var sourceName: String = "—"
    private(set) var destinationName: String = "—"
    var showEditForm = false
    var showDeleteAlert = false

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let deleteTransfer: DeleteTransfer
    private let getAccount: GetAccount

    // MARK: Init

    /// - Parameters:
    ///   - transfer: The transfer to display.
    ///   - toasty: Toaster to display messages to the user.
    ///   - deleteTransfer: UseCase for deleting both transfer legs.
    ///   - getAccount: UseCase for resolving account names from split identifiers.
    init(
        transfer: Transfer,
        toasty: ToastyManager,
        deleteTransfer: DeleteTransfer,
        getAccount: GetAccount
    ) {
        self.transfer = transfer
        self.toasty = toasty
        self.deleteTransfer = deleteTransfer
        self.getAccount = getAccount
    }

    // MARK: Actions

    /// Resolves the source and destination account names from the split identifiers.
    func loadNames() async {
        if let sourceId = transfer.source.splits.first?.accountId,
           let account = try? await getAccount.execute(id: sourceId) {
            sourceName = account.name
        }
        if let destinationId = transfer.destination.splits.first?.accountId,
           let account = try? await getAccount.execute(id: destinationId) {
            destinationName = account.name
        }
    }

    /// Deletes both legs of the transfer and signals the view to dismiss.
    func delete() async {
        do {
            try await deleteTransfer.execute(transfer)
        } catch {
            toasty.showError(error)
        }
    }
}
