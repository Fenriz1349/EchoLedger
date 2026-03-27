//
//  PreviewHelpers.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

extension DIContainer {

    /// Creates an in-memory container for previews.
    static func preview() -> DIContainer {
        DIContainer(inMemory: true)
    }

    func makeAddAccountViewModel() -> AddAccountViewModel {
        AddAccountViewModel(
            addAccount: addAccount,
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

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

    func makeAddTransactionViewModel() -> AddTransactionViewModel {
        AddTransactionViewModel(
            addTransaction: addTransaction,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }
}
