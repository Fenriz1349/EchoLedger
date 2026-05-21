//
//  TransactionFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation
import Toasty

/// Manages form state and submission logic for creating or editing a transaction.
/// The transaction total is always derived from the sum of splits — there is no separate amount field.
@MainActor
@Observable
final class TransactionFormViewModel {

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let addTransaction: AddTransaction
    private let updateTransaction: UpdateTransaction
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let userId: UUID

    // MARK: Form State
    var existingTransaction: Transaction?
    var isExpense: Bool = true
    var category: TransactionCategory = .other
    var date: Date = Date()
    var label: String = ""
    var splits: [TransactionSplit] = []
    var showAddAccountForm = false
    let addAccountFormViewModel: AccountFormViewModel

    // MARK: UI State
    var availableAccounts: [Account] = []
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    /// The sum of all split amounts — used as the transaction total on submit.
    var totalAmount: Double {
        splits.map(\.amount).reduce(0, +)
    }

    /// The first available account not already used by an existing split.
    var nextAvailableAccount: Account? {
        let usedIds = Set(splits.map(\.accountId))
        return availableAccounts.first { !usedIds.contains($0.id) }
    }

    // MARK: Computed

    /// Returns true if the form is ready to be submitted.
    var isValid: Bool {
        guard !splits.isEmpty, totalAmount > 0 else { return false }
        return Set(splits.map(\.accountId)).count == splits.count
    }

    /// Returns the trimmed label, falling back to the category name if empty.
    private var trimmedLabel: String {
        label.trimmingCharacters(in: .whitespaces).isEmpty ? category.name : label
    }

    // MARK: Init
    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - addTransaction: UseCase for creating a new transaction.
    ///   - updateTransaction: UseCase to update a existing transaction.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        addTransaction: AddTransaction,
        updateTransaction: UpdateTransaction,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        userId: UUID,
        addAccountFormViewModel: AccountFormViewModel,
        existingTransaction: Transaction? = nil
    ) {
        self.toasty = toasty
        self.addTransaction = addTransaction
        self.updateTransaction = updateTransaction
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.userId = userId
        self.existingTransaction = existingTransaction
        self.addAccountFormViewModel = addAccountFormViewModel

        if let existing = self.existingTransaction {
            prefillTransaction(with: existing)
        }
    }

    // MARK: Actions

    /// Loads all available accounts. In create mode, initialises the first split automatically.
    func loadAccounts() async {
        do {
            let institutions = try await getInstitutions.execute(for: userId)
            var result: [Account] = []
            for institution in institutions {
                let accounts = try await getAccounts.execute(
                    for: institution.id,
                    filter: existingTransaction == nil ? .active : .all
                )
                result.append(contentsOf: accounts)
            }
            availableAccounts = result
            if existingTransaction == nil, let first = result.first {
                addSplit(for: first)
            }
        } catch {
            toasty.showError(error)
        }
    }

    /// Populates form fields from an existing transaction for editing.
    /// - Parameter transaction: The transaction whose values will pre-fill the form.
    private func prefillTransaction(with transaction: Transaction) {
        label = transaction.label
        isExpense = transaction.isExpense
        category = transaction.category
        splits = transaction.splits
        date = transaction.date
    }

    /// Adds a new split for the given account with a zero amount.
    func addSplit(for account: Account) {
        splits.append(TransactionSplit(accountId: account.id, amount: 0))
    }

    /// Removes a split at the given index.
    func removeSplit(at index: Int) {
        splits.remove(at: index)
    }

    /// Validates and submits the transaction.
    func submit() async {
        guard totalAmount > 0 else {
            errorMessage = TransactionError.invalidTotalAmount.localizedDescription
            return
        }
        guard !splits.isEmpty else {
            errorMessage = TransactionError.missingSplits.localizedDescription
            return
        }
        guard Set(splits.map(\.accountId)).count == splits.count else {
            errorMessage = TransactionError.redundantSplitsAccounts.localizedDescription
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            if let existingTransaction {
                let input = UpdateTransactionInput(
                    id: existingTransaction.id,
                    userId: userId,
                    label: trimmedLabel,
                    date: date,
                    totalAmount: totalAmount,
                    note: nil,
                    isExpense: isExpense,
                    category: category,
                    splits: splits
                )
                try await updateTransaction.execute(input)
            } else {
                let input = AddTransactionInput(
                    userId: userId,
                    label: trimmedLabel,
                    date: date,
                    totalAmount: totalAmount,
                    note: nil,
                    isExpense: isExpense,
                    category: category,
                    splits: splits
                )
                try await addTransaction.execute(input)
            }
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }
}
