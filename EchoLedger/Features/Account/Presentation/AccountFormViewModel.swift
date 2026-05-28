//
//  AccountFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation
import Toasty

/// Manages form state and submission logic for creating or editing an account.
@MainActor
@Observable
final class AccountFormViewModel {

    // MARK: Form State
    var name = ""
    var category: AccountCategory = .checking
    var selectedInstitution: Institution?

    // MARK: UI State
    var existingAccount: Account?
    var institutions: [Institution] = []
    var showAddInstitutionForm = false
    var errorMessage: String?
    var isLoading = false
    var isSuccess = false

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let addAccount: AddAccount
    private let updateAccount: UpdateAccount
    private let getInstitutions: GetInstitutions
    private let userId: UUID
    let addInstitutionFormViewModel: InstitutionFormViewModel

    // MARK: Computed
    /// Returns true if the form is ready to be submitted.
    var isValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2 &&
        selectedInstitution != nil
    }

    // MARK: Init
    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - addAccount: UseCase for creating a new account.
    ///   - updateAccount: UseCase for updating an account.
    ///   - getInstitutions: UseCase for fetching available institutions.
    ///   - addInstitutionFormViewModel: Pre-configured ViewModel for the inline institution creation form.
    ///   - userId: The identifier of the current user.
    ///   - existingAccount: The account to edit. Nil for creation mode.
    init(
        toasty: ToastyManager,
        addAccount: AddAccount,
        updateAccount: UpdateAccount,
        getInstitutions: GetInstitutions,
        addInstitutionFormViewModel: InstitutionFormViewModel,
        userId: UUID,
        existingAccount: Account? = nil
    ) {
        self.toasty = toasty
        self.addAccount = addAccount
        self.updateAccount = updateAccount
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
                try await addAccount.execute(institutionId: institution.id, name: name, category: category)
            }
            isSuccess = true
        } catch let error as AccountError {
            toasty.showError(error)
        } catch {
            toasty.showError("Une erreur est survenue")
        }
        isLoading = false
    }
}
