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
    private let addInstitution: AddInstitution
    private let getInstitutions: GetInstitutions
    private let userId: UUID

    // MARK: Computed
    /// Returns true if the form is ready to be submitted.
    var isValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2 &&
        selectedInstitution != nil
    }

    /// Returns a pre-configured AddInstitutionFormViewModel wired to this ViewModel.
    var addInstitutionFormViewModel: AddInstitutionFormViewModel {
        AddInstitutionFormViewModel(
            toasty: toasty,
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: userId,
            onAdd: { [weak self] institution in
                self?.institutions.append(institution)
                self?.selectedInstitution = institution
                self?.showAddInstitutionForm = false
            }
        )
    }

    // MARK: Init
    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - addAccount: UseCase for creating a new account.
    ///   - updateAccount: UseCase for updating  an account.
    ///   - addInstitution: UseCase for creating a new institution inline.
    ///   - getInstitutions: UseCase for fetching available institutions.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        addAccount: AddAccount,
        updateAccount: UpdateAccount,
        addInstitution: AddInstitution,
        getInstitutions: GetInstitutions,
        userId: UUID,
        existingAccount: Account? = nil
    ) {
        self.toasty = toasty
        self.addAccount = addAccount
        self.updateAccount = updateAccount
        self.addInstitution = addInstitution
        self.getInstitutions = getInstitutions
        self.userId = userId
        self.existingAccount = existingAccount
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
