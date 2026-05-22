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
    var amount: Double = 0
    var date: Date = Date()
    var label: String = ""

    // MARK: UI State

    var availableAccounts: [Account] = []
    var isLoading = false
    var isSuccess = false

    /// True when the form is editing an existing transfer.
    var isEditing: Bool { existingExpense != nil }

    /// True when the form has enough data to submit.
    var isValid: Bool {
        guard let source = sourceAccount,
              let destination = destinationAccount else { return false }
        return source.id != destination.id && amount > 0
    }

    private var trimmedLabel: String {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Transfert" : trimmed
    }

    // MARK: Existing Transfer (edit mode)

    private let existingExpense: Transaction?
    private let existingIncome: Transaction?

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let transferBetweenAccounts: TransferBetweenAccounts
    private let updateTransfer: UpdateTransfer
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let userId: UUID

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display messages to the user.
    ///   - transferBetweenAccounts: UseCase for creating the transfer transactions.
    ///   - updateTransfer: UseCase for updating an existing transfer.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    ///   - existingExpense: The expense leg to edit. Nil for creation mode.
    ///   - existingIncome: The income leg to edit. Nil for creation mode.
    init(
        toasty: ToastyManager,
        transferBetweenAccounts: TransferBetweenAccounts,
        updateTransfer: UpdateTransfer,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        userId: UUID,
        existingExpense: Transaction? = nil,
        existingIncome: Transaction? = nil
    ) {
        self.toasty = toasty
        self.transferBetweenAccounts = transferBetweenAccounts
        self.updateTransfer = updateTransfer
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.userId = userId
        self.existingExpense = existingExpense
        self.existingIncome = existingIncome

        if let expense = existingExpense {
            self.amount = expense.totalAmount
            self.date = expense.date
            self.label = expense.label == "Transfert" ? "" : expense.label
        }
    }

    // MARK: Actions

    /// Loads all active accounts available for transfer, pre-selecting existing accounts in edit mode.
    func loadAccounts() async {
        do {
            let institutions = try await getInstitutions.execute(for: userId)
            var result: [Account] = []
            for institution in institutions {
                let accounts = try await getAccounts.execute(for: institution.id, filter: .active)
                result.append(contentsOf: accounts)
            }
            availableAccounts = result

            if let existingExpense {
                sourceAccount = result.first { $0.id == existingExpense.splits.first?.accountId }
            }
            if let existingIncome {
                destinationAccount = result.first { $0.id == existingIncome.splits.first?.accountId }
            }
            if sourceAccount == nil { sourceAccount = result.first }
            if destinationAccount == nil { destinationAccount = result.dropFirst().first }
        } catch {
            toasty.showError(error)
        }
    }

    /// Validates and submits the transfer (create or update).
    func submit() async {
        guard isValid,
              let source = sourceAccount,
              let destination = destinationAccount else { return }

        isLoading = true
        let input = TransferInput(
            sourceAccountId: source.id,
            destinationAccountId: destination.id,
            amount: amount,
            date: date,
            label: trimmedLabel,
            userId: userId
        )
        do {
            if let existingExpense, let existingIncome {
                try await updateTransfer.execute(
                    expenseId: existingExpense.id,
                    incomeId: existingIncome.id,
                    input: input
                )
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
