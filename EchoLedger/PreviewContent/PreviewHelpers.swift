//
//  PreviewHelpers.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

extension DIContainer {
    
    private static let previewUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    /// Creates an in-memory container for previews.
    static func preview() -> DIContainer {
        DIContainer(inMemory: true)
    }

    /// Creates a preview AddAccountViewModel from this container.
    func makeAddAccountViewModel() -> AddAccountViewModel {
        AddAccountViewModel(
            addAccount: addAccount,
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

    /// Creates a preview AddInstitutionFormViewModel from this container.
    func makeAddInstitutionFormViewModel(onAdd: @escaping (Institution) -> Void = { _ in }
    ) -> AddInstitutionFormViewModel {
        AddInstitutionFormViewModel(
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            onAdd: onAdd
        )
    }
    
    func makeAccountListViewModel() -> AccountListViewModel {
        AccountListViewModel(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }
}
