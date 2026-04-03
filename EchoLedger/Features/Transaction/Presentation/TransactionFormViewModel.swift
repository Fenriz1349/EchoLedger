//
//  TransactionFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation

@MainActor
@Observable
final class TransactionFormViewModel {

    // MARK: Dependencies
    private let addTransaction: AddTransaction
    private let updateTransaction: UpdateTransaction
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let userId: UUID
    private let existingTransaction: Transaction?

    // MARK: Form State
    var amount: String = ""
    var label: String = ""
    var isExpense: Bool = true
    var category: TransactionCategory = .other
    var splits: [TransactionSplit] = []

    // MARK: UI State
    var availableAccounts: [(account: Account, institution: Institution)] = []
    var accountNames: [UUID: String] = [:]
    var selectedAccount: Account?
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    // MARK: Computed

    /// Returns true if the form is ready to be submitted.
    var isValid: Bool {
        guard let total = amount.toDouble, total > 0 else { return false }
        if splits.count == 1 { return true }
        return !splits.isEmpty && splitsMatchTotal
    }

    /// Returns true if the sum of all splits equals the total amount.
    var splitsMatchTotal: Bool {
        guard let total = amount.toDouble else { return false }
        return splits.map(\.amount).reduce(0, +) == total
    }

    /// Returns the remaining amount not yet allocated to a split.
    var remainingAmount: Double {
        (amount.toDouble ?? 0) - splits.map(\.amount).reduce(0, +)
    }

    /// Returns the trimmed label, falling back to the category name if empty.
    private var trimmedLabel: String {
        label.trimmingCharacters(in: .whitespaces).isEmpty ? category.name : label
    }

    // MARK: Init
    /// - Parameters:
    ///   - addTransaction: UseCase for creating a new transaction.
    ///   - updateTransaction: UseCase to update a existing transaction.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(
        addTransaction: AddTransaction,
        updateTransaction: UpdateTransaction,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        userId: UUID,
        existingTransaction: Transaction? = nil
    ) {
        self.addTransaction = addTransaction
        self.updateTransaction = updateTransaction
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.userId = userId
        self.existingTransaction = existingTransaction

        if let existing = self.existingTransaction {
            prefillTransaction(with: existing)
        }
    }

    // MARK: Actions

    /// Loads all available accounts sorted alphabetically and builds the name lookup.
    func loadAccounts() async {
        do {
            let institutions = try await getInstitutions.execute(for: userId)
            var result: [(account: Account, institution: Institution)] = []
            for institution in institutions {
                let accounts = try await getAccounts.execute(for: institution.id)
                for account in accounts {
                    result.append((account: account, institution: institution))
                    accountNames[account.id] = "\(institution.name) — \(account.name)"
                }
            }
            availableAccounts = result.sorted { $0.account.name < $1.account.name }
            selectedAccount = availableAccounts.first?.account
            if existingTransaction == nil, let account = selectedAccount {
                addSplit(for: account)
            }
        } catch {
            errorMessage = "Impossible de charger les comptes"
        }
    }

    private func prefillTransaction(with transaction: Transaction) {
        amount = String(transaction.totalAmount)
        label = transaction.label
        isExpense = transaction.isExpense
        category = transaction.category
        splits = transaction.splits
    }

    /// Adds a new split for the given account with the remaining amount.
    func addSplit(for account: Account) {
        let splitAmount = splits.isEmpty ? (amount.toDouble ?? 0) : remainingAmount
        splits.append(TransactionSplit(accountId: account.id, amount: splitAmount))
    }

    /// Removes a split at the given index.
    func removeSplit(at index: Int) {
        splits.remove(at: index)
    }

    /// Validates and submits the transaction.
    func submit() async {
        guard let total = amount.toDouble, total > 0 else {
            errorMessage = TransactionError.invalidTotalAmount.localizedDescription
            return
        }

        guard !splits.isEmpty else {
            errorMessage = TransactionError.missingSplits.localizedDescription
            return
        }

        isLoading = true
        errorMessage = nil

        if splits.count == 1 {
            splits[0] = TransactionSplit(accountId: splits[0].accountId, amount: total)
        }

        do {
            if let existingTransaction {
                let input = UpdateTransactionInput(
                    id: existingTransaction.id,
                    userId: userId,
                    label: trimmedLabel,
                    date: Date(),
                    totalAmount: total,
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
                    date: Date(),
                    totalAmount: total,
                    note: nil,
                    isExpense: isExpense,
                    category: category,
                    splits: splits
                )
                try await addTransaction.execute(input)
            }
            isSuccess = true
        } catch let error as TransactionError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }
}
