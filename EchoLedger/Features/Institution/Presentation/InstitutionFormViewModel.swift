//
//  InstitutionFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation
import CustomTextFields
import Toasty

/// Manages form state and submission for creating or editing an institution.
/// In creation mode (`existingInstitution` is nil), used inline within AccountFormView.
/// In edit mode, presented as a standalone sheet from AccountListView.
@MainActor
@Observable
final class InstitutionFormViewModel {

    // MARK: Form State
    var name = ""
    var category: InstitutionCategory = .bank
    var nameState: ValidationState = .neutral

    // MARK: UI State
    var errorMessage: String?
    var isLoading = false
    var isSuccess = false
    var showArchiveAlert = false
    var showDeleteAlert = false

    // MARK: Computed

    var isEditing: Bool { existingInstitution != nil }
    var isArchived: Bool { existingInstitution?.isArchived ?? false }

    /// A name is valid when it has at least 2 non-whitespace characters.
    /// Shared by the text field (display) and `isFormValid` (gating) so both stay in sync.
    func isValidName(_ value: String) -> Bool {
        value.trimmingCharacters(in: .whitespaces).count >= 2
    }

    /// True when the form is ready to submit.
    var isFormValid: Bool {
        isValidName(name)
    }

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let addInstitution: AddInstitution
    private let updateInstitution: UpdateInstitution
    private let archiveInstitution: ArchiveInstitution
    private let unarchiveInstitution: UnarchiveInstitution
    private let deleteInstitution: DeleteInstitution
    private let getInstitutions: GetInstitutions
    private let userId: UUID
    private let existingInstitution: Institution?

    /// Called with the newly created institution in creation mode.
    var onAdd: (Institution) -> Void

    // MARK: Init
    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - addInstitution: UseCase for creating a new institution.
    ///   - updateInstitution: UseCase for updating an existing institution.
    ///   - archiveInstitution: UseCase for archiving an institution and its accounts.
    ///   - unarchiveInstitution: UseCase for restoring an institution and its accounts.
    ///   - deleteInstitution: UseCase for permanently deleting an institution and all its data.
    ///   - getInstitutions: UseCase for fetching institutions after creation.
    ///   - userId: The identifier of the current user.
    ///   - existingInstitution: The institution to edit. Nil for creation mode.
    ///   - onAdd: Callback invoked with the newly created institution in creation mode.
    init(
        toasty: ToastyManager,
        addInstitution: AddInstitution,
        updateInstitution: UpdateInstitution,
        archiveInstitution: ArchiveInstitution,
        unarchiveInstitution: UnarchiveInstitution,
        deleteInstitution: DeleteInstitution,
        getInstitutions: GetInstitutions,
        userId: UUID,
        existingInstitution: Institution? = nil,
        onAdd: @escaping (Institution) -> Void = { _ in }
    ) {
        self.toasty = toasty
        self.addInstitution = addInstitution
        self.updateInstitution = updateInstitution
        self.archiveInstitution = archiveInstitution
        self.unarchiveInstitution = unarchiveInstitution
        self.deleteInstitution = deleteInstitution
        self.getInstitutions = getInstitutions
        self.userId = userId
        self.existingInstitution = existingInstitution
        self.onAdd = onAdd

        if let existing = existingInstitution {
            self.name = existing.name
            self.category = existing.category
        }
    }

    // MARK: Actions

    /// Validates and submits the form — creates or updates the institution.
    func submit() async {
        isLoading = true
        errorMessage = nil

        do {
            if let existing = existingInstitution {
                let input = UpdateInstitutionInput(
                    id: existing.id,
                    userId: userId,
                    name: name,
                    category: category,
                    logoURL: existing.logoURL
                )
                try await updateInstitution.execute(input)
                isSuccess = true
            } else {
                let input = AddInstitutionInput(userId: userId, name: name, category: category, logoURL: nil)
                try await addInstitution.execute(input)
                let institutions = try await getInstitutions.execute(for: userId)
                let trimmed = name.trimmingCharacters(in: .whitespaces).lowercased()
                if let created = institutions.first(where: { $0.name.lowercased() == trimmed }) {
                    onAdd(created)
                    isSuccess = true
                    reset()
                }
            }
        } catch let error as InstitutionError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    /// Archives the institution and all its accounts.
    func archive() async {
        guard let existing = existingInstitution else { return }
        isLoading = true
        do {
            try await archiveInstitution.execute(id: existing.id)
            toasty.showSuccess("Établissement archivé.")
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Restores the institution and all its accounts to active status.
    func unarchive() async {
        guard let existing = existingInstitution else { return }
        isLoading = true
        do {
            try await unarchiveInstitution.execute(id: existing.id)
            toasty.showSuccess("Établissement désarchivé.")
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Permanently deletes the institution and all its accounts and transactions.
    func delete() async {
        guard let existing = existingInstitution else { return }
        isLoading = true
        do {
            try await deleteInstitution.execute(id: existing.id)
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Resets the form to its initial state (creation mode only).
    func reset() {
        name = ""
        category = .bank
        errorMessage = nil
        isSuccess = false
    }
}
