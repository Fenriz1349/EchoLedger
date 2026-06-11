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

    var sourceAccount: Account?
    var destinationAccount: Account?
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
        guard let source = sourceAccount,
              let destination = destinationAccount else { return false }
        return source.id != destination.id && amountText.toDouble > 0
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
    private let getAccountsWithInstitution: GetAccountsWithInstitution
    private let userId: UUID

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display messages to the user.
    ///   - transferBetweenAccounts: UseCase for creating the transfer transactions.
    ///   - updateTransfer: UseCase for updating an existing transfer.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    ///   - existingTransfer: The transfer to edit. Nil for creation mode.
    init(
        toasty: ToastyManager,
        transferBetweenAccounts: TransferBetweenAccounts,
        updateTransfer: UpdateTransfer,
        getAccountsWithInstitution: GetAccountsWithInstitution,
        userId: UUID,
        existingTransfer: Transfer? = nil
    ) {
        self.toasty = toasty
        self.transferBetweenAccounts = transferBetweenAccounts
        self.updateTransfer = updateTransfer
        self.getAccountsWithInstitution = getAccountsWithInstitution
        self.userId = userId
        self.existingTransfer = existingTransfer

        if let transfer = existingTransfer {
            self.amountText = String(transfer.amount)
            self.date = transfer.date
            self.label = transfer.label == "Transfert" ? "" : transfer.label
        }
    }

    // MARK: Actions

    /// Loads all active accounts available for transfer, resolves their institution names,
    /// and pre-selects existing accounts in edit mode.
    func loadAccounts() async {
        do {
            let items = try await getAccountsWithInstitution.execute(for: userId, filter: .active)
            availableAccounts = items

            if let existingTransfer {
                sourceAccount = items.first {
                    $0.account.id == existingTransfer.source.splits.first?.accountId
                }?.account
                destinationAccount = items.first {
                    $0.account.id == existingTransfer.destination.splits.first?.accountId
                }?.account
            }
            if sourceAccount == nil { sourceAccount = items.first?.account }
            if destinationAccount == nil { destinationAccount = items.dropFirst().first?.account }
        } catch {
            toasty.showError(error)
        }
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
              let source = sourceAccount,
              let destination = destinationAccount else { return }

        isLoading = true
        let input = TransferFormInput(
            sourceAccountId: source.id,
            destinationAccountId: destination.id,
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
