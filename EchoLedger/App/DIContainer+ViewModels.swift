//
//  DIContainer+ViewModels.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation

/// Factory methods for creating ViewModels with their required dependencies.
extension DIContainer {

    // MARK: - User

    /// Creates a UserProfileViewModel wired with all required dependencies.
    /// - Parameters:
    ///   - authSession: Overrides the container's session. Defaults to the container's current session.
    ///   - onSignOut: Closure called after sign-out or account deletion.
    ///   - onSessionUpdated: Closure called after anonymous account linking.
    func makeUserProfileViewModel(
        authSession: AuthSession? = nil,
        onSignOut: @escaping () -> Void,
        onSessionUpdated: @escaping (AuthSession) -> Void
    ) -> UserProfileViewModel {
        let session = authSession ?? self.authSession
        return UserProfileViewModel(
            toasty: toasty,
            getCurrentUser: getCurrentUser,
            updateUser: updateUser,
            signOut: signOut,
            deleteAccount: deleteAccount,
            linkAnonymousAccount: linkAnonymousAccount,
            resetPassword: resetPassword,
            userStoring: userStoring,
            authSession: session,
            userId: userId,
            daysRemainingInDemo: session.isAnonymous ? authStoring.anonymousDaysRemaining() : nil,
            onSignOut: onSignOut,
            onSessionUpdated: onSessionUpdated
        )
    }

    // MARK: - Account

    /// Creates an AccountListViewModel wired with all required use cases.
    func makeAccountListViewModel() -> AccountListViewModel {
        AccountListViewModel(
            toasty: toasty,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            archiveAccount: archiveAccount,
            unarchiveAccount: unarchiveAccount,
            getAccountBalance: getAccountBalance,
            userId: userId
        )
    }

    /// Creates an AccountFormViewModel. Pass an existing account to pre-fill the form for editing.
    func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        AccountFormViewModel(
            toasty: toasty,
            addAccount: addAccount,
            updateAccount: updateAccount,
            addInstitution: addInstitution,
            getInstitutions: getInstitutions,
            userId: userId,
            existingAccount: existing
        )
    }

    /// Creates an AccountDetailViewModel for a given account.
    func makeAccountDetailViewModel(account: Account) -> AccountDetailViewModel {
        AccountDetailViewModel(
            account: account,
            toasty: toasty,
            getTransactions: getTransactions,
            getAccountBalance: getAccountBalance,
            getAccount: getAccount,
            archiveAccount: archiveAccount,
            unarchiveAccount: unarchiveAccount,
            deleteTransaction: deleteTransaction,
            userId: userId
        )
    }

    // MARK: - Dashboard

    /// Creates a DashboardViewModel wired with all required use cases.
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            toasty: toasty,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            getTransactions: getTransactions,
            userId: userId
        )
    }

    // MARK: - Transfer

    /// Creates a TransferFormViewModel. Pass existing expense and income to pre-fill the form for editing.
    func makeTransferFormViewModel(
        existingExpense: Transaction? = nil,
        existingIncome: Transaction? = nil
    ) -> TransferFormViewModel {
        TransferFormViewModel(
            toasty: toasty,
            transferBetweenAccounts: transferBetweenAccounts,
            updateTransfer: updateTransfer,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: userId,
            existingExpense: existingExpense,
            existingIncome: existingIncome
        )
    }

    /// Creates a TransferDetailViewModel for a given transfer pair.
    func makeTransferDetailViewModel(expense: Transaction, income: Transaction) -> TransferDetailViewModel {
        TransferDetailViewModel(
            expense: expense,
            income: income,
            toasty: toasty,
            deleteTransfer: deleteTransfer,
            getAccount: getAccount
        )
    }

    // MARK: - Transaction

    /// Creates a TransactionListViewModel wired with all required use cases.
    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(
            toasty: toasty,
            getTransactions: getTransactions,
            deleteTransaction: deleteTransaction,
            getAccount: getAccount,
            userId: userId
        )
    }

    /// Creates a TransactionFormViewModel. Pass an existing transaction to pre-fill the form for editing.
    func makeTransactionFormViewModel(existing: Transaction? = nil) -> TransactionFormViewModel {
        TransactionFormViewModel(
            toasty: toasty,
            addTransaction: addTransaction,
            updateTransaction: updateTransaction,
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            userId: userId,
            addAccountFormViewModel: makeAccountFormViewModel(),
            existingTransaction: existing
        )
    }
}
