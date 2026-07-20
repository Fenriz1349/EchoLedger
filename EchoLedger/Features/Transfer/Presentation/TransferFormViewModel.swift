//
//  TransferFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation
import Toasty

/// Manages the state and submission of an internal account transfer form.
/// Supports both creation and editing of an existing transfer.
@MainActor
@Observable
final class TransferFormViewModel {

    // MARK: Form State

    var sourceAccountId: UUID?
    var destinationAccountId: UUID?
    var amountText: String = ""
    var date: Date = Date()
    var label: String = ""

    // MARK: UI State

    var availableAccounts: [AccountDisplayItem] = []
    var isLoading = false
    var isSuccess = false

    /// True when the form is editing an existing transfer.
    var isEditing: Bool { existingTransfer != nil }

    /// True when the form has enough data to submit.
    var isFormValid: Bool {
        guard let sourceAccountId, let destinationAccountId else { return false }
        return sourceAccountId != destinationAccountId && amountText.toDouble > 0
    }

    /// Accounts selectable as source — every available account except the current destination.
    /// Never excludes the current source itself, even if it transiently matches the destination
    /// mid-swap, so the Picker's selection always has a matching tag.
    var sourceOptions: [AccountDisplayItem] {
        availableAccounts.filter { $0.account.id != destinationAccountId || $0.account.id == sourceAccountId }
    }

    /// Accounts selectable as destination — every available account except the current source.
    /// Never excludes the current destination itself, even if it transiently matches the source
    /// mid-swap, so the Picker's selection always has a matching tag.
    var destinationOptions: [AccountDisplayItem] {
        availableAccounts.filter { $0.account.id != sourceAccountId || $0.account.id == destinationAccountId }
    }

    private var trimmedLabel: String {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Transfert" : trimmed
    }

    // MARK: Existing Transfer (edit mode)

    private let existingTransfer: Transfer?

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let transferBetweenAccounts: TransferBetweenAccounts
    private let updateTransfer: UpdateTransfer
    private let getAccountsSortedByRecency: GetAccountsSortedByRecency
    private let userId: UUID

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display messages to the user.
    ///   - transferBetweenAccounts: UseCase for creating the transfer transactions.
    ///   - updateTransfer: UseCase for updating an existing transfer.
    ///   - getAccountsSortedByRecency: UseCase for fetching accounts ordered by last use.
    ///   - userId: The identifier of the current user.
    ///   - existingTransfer: The transfer to edit. Nil for creation mode.
    init(
        toasty: ToastyManager,
        transferBetweenAccounts: TransferBetweenAccounts,
        updateTransfer: UpdateTransfer,
        getAccountsSortedByRecency: GetAccountsSortedByRecency,
        userId: UUID,
        existingTransfer: Transfer? = nil
    ) {
        self.toasty = toasty
        self.transferBetweenAccounts = transferBetweenAccounts
        self.updateTransfer = updateTransfer
        self.getAccountsSortedByRecency = getAccountsSortedByRecency
        self.userId = userId
        self.existingTransfer = existingTransfer

        if let transfer = existingTransfer {
            self.amountText = String(transfer.amount)
            self.date = transfer.date
            self.label = transfer.label == "Transfert" ? "" : transfer.label
        }
    }

    // MARK: Actions

    /// Loads all active accounts available for transfer, ordered by last use, resolves their
    /// institution names, and pre-selects existing accounts in edit mode.
    func loadAccounts() async {
        do {
            let items = try await getAccountsSortedByRecency.execute(for: userId, filter: .active)
            availableAccounts = items

            if let existingTransfer {
                sourceAccountId = items.first {
                    $0.account.id == existingTransfer.source.splits.first?.accountId
                }?.account.id
                destinationAccountId = items.first {
                    $0.account.id == existingTransfer.destination.splits.first?.accountId
                }?.account.id
            }
            if sourceAccountId == nil { sourceAccountId = items.first?.account.id }
            if destinationAccountId == nil {
                destinationAccountId = items.first { $0.account.id != sourceAccountId }?.account.id
            }
        } catch {
            toasty.showError(error)
        }
    }

    /// Swaps the source and destination accounts.
    func swapAccounts() {
        swap(&sourceAccountId, &destinationAccountId)
    }

    /// Strips any non-numeric character from the amount field, keeping digits and a single separator.
    /// Reassigns only when something was removed, so typing a separator isn't disrupted.
    func sanitizeAmount() {
        let filtered = amountText.numericOnly
        if filtered != amountText {
            amountText = filtered
        }
    }

    /// Validates and submits the transfer (create or update).
    func submit() async {
        guard isFormValid,
              let sourceAccountId,
              let destinationAccountId else { return }

        isLoading = true
        let input = TransferFormInput(
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            amount: amountText.toDouble,
            date: date,
            label: trimmedLabel,
            userId: userId
        )
        do {
            if let existingTransfer {
                try await updateTransfer.execute(existingTransfer, input: input)
            } else {
                try await transferBetweenAccounts.execute(input)
            }
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }
}
