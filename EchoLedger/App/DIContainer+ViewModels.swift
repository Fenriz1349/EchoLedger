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
            uploadAvatarPhoto: uploadAvatarPhoto,
            getUserPhoto: getUserPhoto,
            userStoring: userStoring,
            authSession: session,
            userId: userId,
            daysRemainingInDemo: session.isAnonymous ? authStoring.anonymousDaysRemaining() : nil,
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
            archiveInstitution: archiveInstitution,
            unarchiveInstitution: unarchiveInstitution,
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
            getInstitutions: getInstitutions,
            addInstitutionFormViewModel: makeInstitutionFormViewModel(),
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
            deleteTransfer: deleteTransfer,
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
            userId: userId,
            addAccountFormViewModel: makeAccountFormViewModel(),
            existingTransaction: existing
        )
    }
}
