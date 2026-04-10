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

    /// Creates a TransactionListViewModel wired with all required use cases.
    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(
            getTransactions: getTransactions,
            deleteTransaction: deleteTransaction,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }
    
    /// Creates a TransactionFormViewModel. Pass an existing transaction to pre-fill the form for editing.
    func makeTransactionFormViewModel(existing: Transaction? = nil) -> TransactionFormViewModel {
        TransactionFormViewModel(
            addTransaction: addTransaction,
            updateTransaction: updateTransaction,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            addAccountFormViewModel: makeAccountFormViewModel(),
            existingTransaction: existing
        )
    }

    // MARK: - Account

    /// Creates an AccountListViewModel wired with all required use cases.
    func makeAccountListViewModel() -> AccountListViewModel {
        AccountListViewModel(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            archiveAccount: archiveAccount,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

    /// Creates an AccountFormViewModel. Pass an existing account to pre-fill the form for editing.
    func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        AccountFormViewModel(
            addAccount: addAccount,
            updateAccount: updateAccount,
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            existingAccount: existing
        )
    }
}
