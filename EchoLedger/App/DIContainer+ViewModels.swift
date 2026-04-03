//
//  DIContainer+ViewModels.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation

/// Factory methods for creating ViewModels with their required dependencies.
extension DIContainer {

    // MARK: - Transaction
    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(
            getTransactions: getTransactions,
            deleteTransaction: deleteTransaction,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }
    
    func makeTransactionFormViewModel(existing: Transaction? = nil) -> TransactionFormViewModel {
        TransactionFormViewModel(
            addTransaction: addTransaction,
            updateTransaction: updateTransaction,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            existingTransaction: existing
        )
    }

    // MARK: - Account
    func makeAccountListViewModel() -> AccountListViewModel {
        AccountListViewModel(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

    func makeAccountFormViewModel() -> AccountFormViewModel {
        AccountFormViewModel(
            addAccount: addAccount,
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }
}
