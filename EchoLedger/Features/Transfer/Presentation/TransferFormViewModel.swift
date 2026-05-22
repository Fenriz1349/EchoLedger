//
//  TransferFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation
import Toasty

/// Manages the state and submission of an internal account transfer form.
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

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let transferBetweenAccounts: TransferBetweenAccounts
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let userId: UUID

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display messages to the user.
    ///   - transferBetweenAccounts: UseCase for creating the transfer transactions.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        transferBetweenAccounts: TransferBetweenAccounts,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        userId: UUID
    ) {
        self.toasty = toasty
        self.transferBetweenAccounts = transferBetweenAccounts
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.userId = userId
    }

    // MARK: Actions

    /// Loads all active accounts available for transfer.
    func loadAccounts() async {
        do {
            let institutions = try await getInstitutions.execute(for: userId)
            var result: [Account] = []
            for institution in institutions {
                let accounts = try await getAccounts.execute(for: institution.id, filter: .active)
                result.append(contentsOf: accounts)
            }
            availableAccounts = result
            sourceAccount = result.first
            destinationAccount = result.dropFirst().first
        } catch {
            toasty.showError(error)
        }
    }

    /// Validates and submits the transfer.
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
            try await transferBetweenAccounts.execute(input)
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }
}
