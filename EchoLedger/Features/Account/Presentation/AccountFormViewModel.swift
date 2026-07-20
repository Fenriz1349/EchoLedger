//
//  AccountFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation
import CustomTextFields
import Toasty

/// Manages form state and submission logic for creating or editing an account.
@MainActor
@Observable
final class AccountFormViewModel {

    // MARK: Form State
    var name = ""
    var nameState: ValidationState = .neutral
    var category: AccountCategory = .checking
    var selectedInstitution: Institution?
    var initialBalanceText: String = ""
    var isInitialBalanceExpense: Bool = false
    /// Date of the initial balance transaction: the account's real opening date, not today.
    var initialBalanceDate: Date = Date()

    // MARK: UI State
    var existingAccount: Account?
    var institutions: [Institution] = []
    var showAddInstitutionForm = false
    var showDeleteAlert = false
    var errorMessage: String?
    var isLoading = false
    var isSuccess = false

    // MARK: Computed
    var isEditing: Bool { existingAccount != nil }
    var isArchived: Bool { existingAccount?.isArchived ?? false }

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let addAccount: AddAccount
    private let updateAccount: UpdateAccount
    private let archiveAccount: ArchiveAccount
    private let unarchiveAccount: UnarchiveAccountRule
    private let deleteAccount: DeleteAccountRule
    private let addTransaction: AddTransaction
    private let getInstitutions: GetInstitutions
    private let userId: UUID
    let addInstitutionFormViewModel: InstitutionFormViewModel

    // MARK: Computed
    /// A name is valid when it has at least 2 non-whitespace characters.
    /// Shared by the text field (display) and `isFormValid` (gating) so both stay in sync.
    func isValidName(_ value: String) -> Bool {
        value.trimmingCharacters(in: .whitespaces).count >= 2
    }

    /// Returns true if the form is ready to be submitted.
    var isFormValid: Bool {
        isValidName(name) && selectedInstitution != nil
    }

    /// Strips any non-numeric character from the initial balance field, keeping only digits
    /// and decimal separators (a hardware keyboard bypasses `.decimalPad`).
    /// Reassigns only when something was actually removed, so typing a separator isn't disrupted.
    func sanitizeBalance() {
        let filtered = initialBalanceText.numericOnly
        if filtered != initialBalanceText {
            initialBalanceText = filtered
        }
    }

    // MARK: Init
    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - addAccount: UseCase for creating a new account.
    ///   - updateAccount: UseCase for updating an account.
    ///   - archiveAccount: UseCase for archiving an account.
    ///   - unarchiveAccount: UseCase for restoring an archived account.
    ///   - deleteAccount: UseCase for permanently deleting an account and its transactions.
    ///   - addTransaction: UseCase for creating the initial balance transaction.
    ///   - getInstitutions: UseCase for fetching available institutions.
    ///   - addInstitutionFormViewModel: Pre-configured ViewModel for the inline institution creation form.
    ///   - userId: The identifier of the current user.
    ///   - existingAccount: The account to edit. Nil for creation mode.
    init(
        toasty: ToastyManager,
        addAccount: AddAccount,
        updateAccount: UpdateAccount,
        archiveAccount: ArchiveAccount,
        unarchiveAccount: UnarchiveAccountRule,
        deleteAccount: DeleteAccountRule,
        addTransaction: AddTransaction,
        getInstitutions: GetInstitutions,
        addInstitutionFormViewModel: InstitutionFormViewModel,
        userId: UUID,
        existingAccount: Account? = nil
    ) {
        self.toasty = toasty
        self.addAccount = addAccount
        self.updateAccount = updateAccount
        self.archiveAccount = archiveAccount
        self.unarchiveAccount = unarchiveAccount
        self.deleteAccount = deleteAccount
        self.addTransaction = addTransaction
        self.getInstitutions = getInstitutions
        self.addInstitutionFormViewModel = addInstitutionFormViewModel
        self.userId = userId
        self.existingAccount = existingAccount

        addInstitutionFormViewModel.onAdd = { [weak self] institution in
            self?.institutions.append(institution)
            self?.selectedInstitution = institution
            self?.showAddInstitutionForm = false
        }

        if let existing = existingAccount {
            prefill(with: existing)
        }
    }

    /// Prefills the form with an existing account's data.
    private func prefill(with account: Account) {
        name = account.name
        category = account.category
    }

    // MARK: Actions

    /// Loads available institutions and pre-selects the first one.
    func loadInstitutions() async {
        do {
            institutions = try await getInstitutions.execute(for: userId)
            if let existing = existingAccount {
                selectedInstitution = institutions.first { $0.id == existing.institutionId }
            }
            if selectedInstitution == nil {
                selectedInstitution = institutions.first
            }
        } catch {
            toasty.showError(error)
        }
    }

    /// Archives the account and shows a confirmation toast.
    func archive() async {
        guard let existing = existingAccount else { return }
        isLoading = true
        do {
            try await archiveAccount.execute(id: existing.id)
            existingAccount = Account(
                id: existing.id,
                institutionId: existing.institutionId,
                name: existing.name,
                category: existing.category,
                isArchived: true
            )
            toasty.showSuccess("Compte archivé.")
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Restores the account and shows a confirmation toast.
    func unarchive() async {
        guard let existing = existingAccount else { return }
        isLoading = true
        do {
            try await unarchiveAccount.execute(id: existing.id)
            existingAccount = Account(
                id: existing.id,
                institutionId: existing.institutionId,
                name: existing.name,
                category: existing.category,
                isArchived: false
            )
            toasty.showSuccess("Compte désarchivé.")
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Permanently deletes the account and all its linked transactions.
    func delete() async {
        guard let existing = existingAccount else { return }
        isLoading = true
        do {
            try await deleteAccount.execute(id: existing.id)
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Validates and creates / update an account for the selected institution.
    func submit() async {
        guard let institution = selectedInstitution else { return }
        isLoading = true
        errorMessage = nil

        do {
            if let existing = existingAccount {
                let input = UpdateAccountInput(
                    id: existing.id,
                    institutionId: institution.id,
                    name: name,
                    category: category
                )
                try await updateAccount.execute(input)
            } else {
                let account = try await addAccount.execute(
                    institutionId: institution.id,
                    name: name,
                    category: category
                )
                let amount = initialBalanceText.toDouble
                let input = AddTransactionInput(
                    userId: userId,
                    label: "Solde initial",
                    date: initialBalanceDate,
                    totalAmount: amount,
                    note: nil,
                    isExpense: isInitialBalanceExpense,
                    category: .initialBalance,
                    splits: [TransactionSplit(accountId: account.id, amount: amount)]
                )
                try await addTransaction.execute(input)
            }
            isSuccess = true
        } catch {
            toasty.showError((error as? LocalizedError)?.errorDescription ?? "Une erreur est survenue")
        }
        isLoading = false
    }
}
