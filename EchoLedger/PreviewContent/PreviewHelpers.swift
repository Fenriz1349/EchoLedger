//
//  PreviewHelpers.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation
import SwiftData

/// Provides pre-configured ViewModels and a seeded DIContainer for SwiftUI previews.
struct PreviewHelpers {

    static let container = DIContainer(
        userId: PreviewData.user.id,
        toasty: PreviewData.toasty,
        authStoring: PreviewData.authStoring,
        authSession: PreviewData.authSession,
        networkMonitor: PreviewData.networkMonitor,
        inMemory: true
    )

    /// Seeds all preview institutions and accounts into SwiftData.
    /// Idempotent: skips if already seeded (shared container across previews).
    private static func seedInstitutionsAndAccounts() {
        let context = container.modelContainer.mainContext
        let alreadySeeded = !((try? context.fetch(FetchDescriptor<InstitutionModel>()))?.isEmpty ?? true)
        guard !alreadySeeded else { return }
        for institution in PreviewData.institutions {
            let model = InstitutionModel(
                id: institution.id,
                userId: institution.userId,
                name: institution.name,
                category: institution.category.rawValue,
                isArchived: institution.isArchived
            )
            context.insert(model)
        }
        for account in PreviewData.accounts {
            let model = AccountModel(
                id: account.id,
                institutionId: account.institutionId,
                name: account.name,
                category: account.category.rawValue
            )
            context.insert(model)
        }
        try? context.save()
    }

    /// Seeds all preview transactions and splits into SwiftData.
    /// Includes the multi-month `chartTransactions` so dashboard/chart previews are populated.
    /// Idempotent: skips if transactions are already seeded (shared container across previews).
    private static func seedTransactions() {
        let context = container.modelContainer.mainContext
        let alreadySeeded = !((try? context.fetch(FetchDescriptor<TransactionModel>()))?.isEmpty ?? true)
        guard !alreadySeeded else { return }
        for transaction in PreviewData.transactions + PreviewData.chartTransactions {
            let model = TransactionModel(
                id: transaction.id,
                userId: transaction.userId,
                label: transaction.label,
                date: transaction.date,
                totalAmount: transaction.totalAmount,
                note: transaction.note,
                isExpense: transaction.isExpense,
                category: transaction.category.rawValue
            )
            model.splits = transaction.splits.map {
                TransactionSplitModel(id: $0.id, accountId: $0.accountId, amount: $0.amount)
            }
            context.insert(model)
        }
        try? context.save()
    }

    /// Seeds the preview user into SwiftData.
    private static func seedUser() {
        let context = container.modelContainer.mainContext
        let id = PreviewData.user.id
        let descriptor = FetchDescriptor<UserModel>(predicate: #Predicate { $0.id == id })
        guard (try? context.fetch(descriptor))?.isEmpty != false else { return }
        let model = UserModel(
            id: PreviewData.user.id,
            displayName: PreviewData.user.displayName,
            email: PreviewData.user.email,
            photoURL: PreviewData.user.photoURL
        )
        context.insert(model)
        try? context.save()
    }

    /// Creates a preview AppCoordinator with seeded data.
    static var appCoordinator: AppCoordinator {
        seedUser()
        seedInstitutionsAndAccounts()
        seedTransactions()
        let coordinator = AppCoordinator(
            container: container,
            user: PreviewData.user,
            onSignOut: {},
            onSessionUpdated: { _ in }
        )
        Task { await coordinator.loadData() }
        return coordinator
    }

    /// - Returns: A UserProfileViewModel with the preview user pre-seeded in SwiftData.
    static func makeUserProfileViewModel(
        isAnonymous: Bool = false,
        onSignOut: @escaping () -> Void = {},
        onSessionUpdated: @escaping (AuthSession) -> Void = { _ in }
    ) -> UserProfileViewModel {
        seedUser()
        return container.makeUserProfileViewModel(
            user: PreviewData.user,
            onSignOut: onSignOut,
            onSessionUpdated: onSessionUpdated
        )
    }

    /// - Returns: An AccountFormViewModel seeded with preview institutions and accounts.
    static func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        seedInstitutionsAndAccounts()
        return container.makeAccountFormViewModel(existing: existing)
    }

    /// - Parameter onAdd: Callback invoked when an institution is created. Defaults to a no-op.
    /// - Returns: An InstitutionFormViewModel in creation mode.
    static func makeAddInstitutionFormViewModel(onAdd: @escaping (Institution) -> Void = { _ in })
    -> InstitutionFormViewModel {
        container.makeInstitutionFormViewModel(onAdd: onAdd)
    }

    /// - Parameter existing: An optional institution to pre-fill the form for editing.
    /// - Returns: An InstitutionFormViewModel wired to the preview container.
    static func makeInstitutionFormViewModel(existing: Institution? = nil) -> InstitutionFormViewModel {
        seedInstitutionsAndAccounts()
        return container.makeInstitutionFormViewModel(existing: existing)
    }

    /// - Returns: An AccountListViewModel seeded with preview institutions and accounts.
    static func makeAccountListViewModel() -> AccountListViewModel {
        seedInstitutionsAndAccounts()
        return AccountListViewModel(
            toasty: container.toasty,
            getInstitutions: container.getInstitutions,
            getAccounts: container.getAccounts,
            archiveAccount: container.archiveAccount,
            unarchiveAccount: container.unarchiveAccountRule,
            deleteAccount: container.deleteAccountRule,
            getAccountBalance: container.getAccountBalance,
            refreshFromRemote: container.refreshFromRemote,
            userId: container.userId
        )
    }

    /// - Returns: A TransactionFormViewModel seeded with preview institutions and accounts.
    static func makeTransactionFormViewModel() -> TransactionFormViewModel {
        seedInstitutionsAndAccounts()
        return TransactionFormViewModel(
            toasty: container.toasty,
            addTransaction: container.addTransaction,
            updateTransaction: container.updateTransaction,
            getAccountsSortedByRecency: container.getAccountsSortedByRecency,
            uploadTransactionDocument: container.uploadTransactionDocument,
            getTransactionDocument: container.getTransactionDocument,
            deleteDocument: container.deleteDocument,
            userId: container.userId,
            authSession: container.authSession,
            addAccountFormViewModel: container.makeAccountFormViewModel()
        )
    }

    /// - Returns: A TransferFormViewModel seeded with preview institutions and accounts.
    static var transferFormViewModel: TransferFormViewModel {
        seedInstitutionsAndAccounts()
        return container.makeTransferFormViewModel()
    }

    /// - Returns: A TransactionListViewModel seeded with preview transactions.
    static func makeTransactionListViewModel() -> TransactionListViewModel {
        seedTransactions()
        return TransactionListViewModel(
            toasty: container.toasty,
            getTransactions: container.getTransactions,
            deleteTransaction: container.deleteTransaction,
            getAccount: container.getAccount,
            getAccountsWithInstitution: container.getAccountsWithInstitution,
            refreshFromRemote: container.refreshFromRemote,
            userId: container.userId
        )
    }
}
