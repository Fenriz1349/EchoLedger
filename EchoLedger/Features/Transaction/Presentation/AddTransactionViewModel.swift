//
//  AddTransactionViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation

@MainActor
@Observable
final class AddTransactionViewModel {

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
    /// Returns the parsed total amount from the string input.
    var totalAmount: Decimal {
        Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    /// Returns true if the form is ready to be submitted.
    var isValid: Bool {
        if splits.count == 1 {
            return totalAmount > 0
        }
        return totalAmount > 0 && !splits.isEmpty && splitsMatchTotal
    }

    /// Returns true if the sum of all splits equals the total amount.
    var splitsMatchTotal: Bool {
        splits.map(\.amount).reduce(0, +) == totalAmount
    }

    /// Returns the remaining amount not yet allocated to a split.
    var remainingAmount: Decimal {
        totalAmount - splits.map(\.amount).reduce(0, +)
    }

    // MARK: Dependencies
    private let addTransaction: AddTransaction
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let userId: UUID

    // MARK: Init
    /// - Parameters:
    ///   - addTransaction: UseCase for creating a new transaction.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(
        addTransaction: AddTransaction,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        userId: UUID
    ) {
        self.addTransaction = addTransaction
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.userId = userId
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
            if let account = selectedAccount {
                addSplit(for: account)
            }
        } catch {
            errorMessage = "Impossible de charger les comptes"
        }
    }

    /// Adds a new split for the given account with the remaining amount.
    func addSplit(for account: Account) {
        let splitAmount = splits.isEmpty ? totalAmount : remainingAmount
        splits.append(TransactionSplit(accountId: account.id, amount: splitAmount))
    }

    /// Removes a split at the given index.
    func removeSplit(at index: Int) {
        splits.remove(at: index)
    }

    /// Validates and submits the transaction.
    func submit() async {
        isLoading = true
        errorMessage = nil

        if splits.count == 1 {
            splits[0] = TransactionSplit(accountId: splits[0].accountId, amount: totalAmount)
        }

        let input = AddTransactionInput(
            userId: userId,
            label: label.trimmingCharacters(in: .whitespaces).isEmpty ? category.name : label,
            date: Date(),
            totalAmount: totalAmount,
            note: nil,
            isExpense: isExpense,
            category: category,
            splits: splits
        )
        do {
            try await addTransaction.execute(input)
            isSuccess = true
        } catch let error as TransactionError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }
}
