//
//  AddAccountViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

@MainActor
@Observable
final class AddAccountViewModel {

    // MARK: Form State
    var name = ""
    var type: AccountType = .checking
    var selectedInstitution: Institution?

    // MARK: UI State
    var institutions: [Institution] = []
    var showAddInstitutionForm = false
    var errorMessage: String?
    var isLoading = false
    var isSuccess = false

    // MARK: Dependencies
    private let addAccount: AddAccount
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
    ///   - addAccount: UseCase for creating a new account.
    ///   - addInstitution: UseCase for creating a new institution inline.
    ///   - getInstitutions: UseCase for fetching available institutions.
    ///   - userId: The identifier of the current user.
    init(
        addAccount: AddAccount,
        addInstitution: AddInstitution,
        getInstitutions: GetInstitutions,
        userId: UUID
    ) {
        self.addAccount = addAccount
        self.addInstitution = addInstitution
        self.getInstitutions = getInstitutions
        self.userId = userId
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
            errorMessage = "Impossible de charger les établissements"
        }
    }

    /// Validates and creates a new account for the selected institution.
    func submit() async {
        guard let institution = selectedInstitution else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await addAccount.execute(institutionId: institution.id, name: name, type: type)
            isSuccess = true
        } catch let error as AccountError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }
}
