//
//  AddInstitutionFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

@MainActor
@Observable
final class AddInstitutionFormViewModel {

    // MARK: Form State
    var name = ""
    var type: InstitutionType = .bank

    // MARK: UI State
    var errorMessage: String?
    var isLoading = false

    // MARK: Dependencies
    private let addInstitution: AddInstitution
    private let getInstitutions: GetInstitutions
    private let userId: UUID
    var onAdd: (Institution) -> Void

    // MARK: Computed
    /// Returns true if the form is ready to be submitted.
    var isValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }

    // MARK: Init
    /// - Parameters:
    ///   - addInstitution: UseCase for creating a new institution.
    ///   - getInstitutions: UseCase for fetching institutions after creation.
    ///   - userId: The identifier of the current user.
    ///   - onAdd: Callback invoked with the newly created institution.
    init(
        addInstitution: AddInstitution,
        getInstitutions: GetInstitutions,
        userId: UUID,
        onAdd: @escaping (Institution) -> Void
    ) {
        self.addInstitution = addInstitution
        self.getInstitutions = getInstitutions
        self.userId = userId
        self.onAdd = onAdd
    }

    // MARK: Actions

    /// Validates and creates a new institution, then notifies the parent via onAdd.
    func submit() async {
        isLoading = true
        errorMessage = nil
        let input = AddInstitutionInput(userId: userId, name: name, type: type, logoURL: nil)
        do {
            try await addInstitution.execute(input)
            let institutions = try await getInstitutions.execute(for: userId)
            let trimmed = name.trimmingCharacters(in: .whitespaces).lowercased()
            if let created = institutions.first(where: { $0.name.lowercased() == trimmed }) {
                onAdd(created)
                reset()
            }
        } catch let error as InstitutionError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    /// Resets the form to its initial state.
    func reset() {
        name = ""
        type = .bank
        errorMessage = nil
    }
}
