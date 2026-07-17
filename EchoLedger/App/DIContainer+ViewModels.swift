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
    ///   - user: The loaded user profile.
    ///   - onSignOut: Closure called after sign-out or account deletion.
    ///   - onSessionUpdated: Closure called after anonymous account linking.
    func makeUserProfileViewModel(
        user: User,
        onSignOut: @escaping () -> Void,
        onSessionUpdated: @escaping (AuthSession) -> Void
    ) -> UserProfileViewModel {
        UserProfileViewModel(
            toasty: toasty,
            user: user,
            updateUser: updateUser,
            signOut: signOut,
            deleteUserRule: deleteUserRule,
            linkAnonymousAccount: linkAnonymousAccount,
            resetPassword: resetPassword,
            uploadAvatarPhoto: uploadAvatarPhoto,
            downloadImage: downloadImage,
            authSession: authSession,
            userId: userId,
            daysRemainingInDemo: authSession.isAnonymous ? authStoring.anonymousDaysRemaining() : nil,
            onSignOut: onSignOut,
            onSessionUpdated: onSessionUpdated
        )
    }

    // MARK: - Institution

    /// Creates an InstitutionFormViewModel. Pass an existing institution to pre-fill for editing.
    func makeInstitutionFormViewModel(
        existing: Institution? = nil,
        onAdd: @escaping (Institution) -> Void = { _ in }
    ) -> InstitutionFormViewModel {
        InstitutionFormViewModel(
            toasty: toasty,
            addInstitution: addInstitution,
            updateInstitution: updateInstitution,
            archiveInstitution: archiveInstitutionRule,
            unarchiveInstitution: unarchiveInstitutionRule,
            deleteInstitution: deleteInstitutionRule,
            getInstitutions: getInstitutions,
            userId: userId,
            existingInstitution: existing,
            onAdd: onAdd
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
            unarchiveAccount: unarchiveAccountRule,
            deleteAccount: deleteAccountRule,
            getAccountBalance: getAccountBalance,
            refreshFromRemote: refreshFromRemote,
            userId: userId
        )
    }

    /// Creates an AccountFormViewModel. Pass an existing account to pre-fill the form for editing.
    func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        AccountFormViewModel(
            toasty: toasty,
            addAccount: addAccount,
            updateAccount: updateAccount,
            archiveAccount: archiveAccount,
            unarchiveAccount: unarchiveAccountRule,
            deleteAccount: deleteAccountRule,
            addTransaction: addTransaction,
            getInstitutions: getInstitutions,
            addInstitutionFormViewModel: makeInstitutionFormViewModel(),
            userId: userId,
            existingAccount: existing
        )
    }

    /// Creates an AccountDetailViewModel for a given account with its own GraphsViewModel scoped to that account.
    func makeAccountDetailViewModel(account: Account) -> AccountDetailViewModel {
        AccountDetailViewModel(
            account: account,
            toasty: toasty,
            graphsViewModel: makeGraphsViewModel(),
            getTransactions: getTransactions,
            getAccount: getAccount,
            archiveAccount: archiveAccount,
            unarchiveAccount: unarchiveAccountRule,
            deleteTransaction: deleteTransaction,
            deleteTransfer: deleteTransfer,
            userId: userId
        )
    }

    // MARK: - Dashboard

    /// Creates a GraphsViewModel wired to the shared GetChartData use case.
    func makeGraphsViewModel() -> GraphsViewModel {
        GraphsViewModel(getChartData: getChartData)
    }

    /// Creates a DashboardViewModel with its own GraphsViewModel for the global scope.
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            toasty: toasty,
            refreshFromRemote: refreshFromRemote,
            graphsViewModel: makeGraphsViewModel()
        )
    }

    // MARK: - Transfer

    /// Creates a TransferDetailViewModel for a given transfer.
    func makeTransferDetailViewModel(transfer: Transfer) -> TransferDetailViewModel {
        TransferDetailViewModel(
            transfer: transfer,
            toasty: toasty,
            deleteTransfer: deleteTransfer,
            getAccount: getAccount
        )
    }

    /// Creates a TransferFormViewModel. Pass an existing transfer to pre-fill the form for editing.
    func makeTransferFormViewModel(existing: Transfer? = nil) -> TransferFormViewModel {
        TransferFormViewModel(
            toasty: toasty,
            transferBetweenAccounts: transferBetweenAccounts,
            updateTransfer: updateTransfer,
            getAccountsWithInstitution: getAccountsWithInstitution,
            getLastUsedAccount: getLastUsedAccount,
            userId: userId,
            existingTransfer: existing
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
            getAccountsWithInstitution: getAccountsWithInstitution,
            refreshFromRemote: refreshFromRemote,
            userId: userId
        )
    }

    /// Creates a TransactionFormViewModel. Pass an existing transaction to pre-fill the form for editing.
    func makeTransactionFormViewModel(existing: Transaction? = nil) -> TransactionFormViewModel {
        TransactionFormViewModel(
            toasty: toasty,
            addTransaction: addTransaction,
            updateTransaction: updateTransaction,
            getAccountsWithInstitution: getAccountsWithInstitution,
            getLastUsedAccount: getLastUsedAccount,
            uploadTransactionDocument: uploadTransactionDocument,
            getTransactionDocument: getTransactionDocument,
            deleteDocument: deleteDocument,
            userId: userId,
            authSession: authSession,
            addAccountFormViewModel: makeAccountFormViewModel(),
            existingTransaction: existing
        )
    }
}
