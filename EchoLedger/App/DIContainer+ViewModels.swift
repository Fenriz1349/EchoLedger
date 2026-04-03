//
//  DIContainer+ViewModels.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation

extension DIContainer {

    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(
            getTransactions: getTransactions,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

    func makeAccountListViewModel() -> AccountListViewModel {
        AccountListViewModel(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

    func makeAddAccountViewModel() -> AccountFormViewModel {
        AccountFormViewModel(
            addAccount: addAccount,
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

    func makeAddTransactionViewModel() -> TransactionFormViewModel {
        TransactionFormViewModel(
            addTransaction: addTransaction,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }
}
