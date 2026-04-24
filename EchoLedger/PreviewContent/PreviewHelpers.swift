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
        inMemory: true
    )

    /// Seeds all preview institutions and accounts into SwiftData.
    private static func seedInstitutionsAndAccounts() {
        let context = container.modelContainer.mainContext
        for institution in PreviewData.institutions {
            let model = InstitutionModel(
                id: institution.id,
                userId: institution.userId,
                name: institution.name,
                category: institution.category.rawValue
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
    private static func seedTransactions() {
        let context = container.modelContainer.mainContext
        for transaction in PreviewData.transactions {
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

    /// Creates a preview AppCoordinator with seeded data.
    static var appCoordinator: AppCoordinator {
        seedInstitutionsAndAccounts()
        seedTransactions()
        return AppCoordinator(container: container, onSignOut: {})
    }

    /// - Returns: An AccountFormViewModel seeded with preview institutions and accounts.
    static func makeccountFormViewModel() -> AccountFormViewModel {
        seedInstitutionsAndAccounts()
        return AccountFormViewModel(
            toasty: container.toasty,
            addAccount: container.addAccount,
            updateAccount: container.updateAccount,
            addInstitution: container.addInstitution,
            getInstitutions: container.getInstitutions,
            userId: container.userId
        )
    }

    /// - Parameter onAdd: Callback invoked when an institution is created. Defaults to a no-op.
    /// - Returns: An AddInstitutionFormViewModel wired to the preview container.
    static func makeAddInstitutionFormViewModel(onAdd: @escaping (Institution) -> Void = { _ in })
    -> AddInstitutionFormViewModel {
        return AddInstitutionFormViewModel(
            toasty: container.toasty,
            addInstitution: container.addInstitution,
            getInstitutions: container.getInstitutions,
            userId: container.userId,
            onAdd: onAdd
        )
    }

    /// - Returns: An AccountListViewModel seeded with preview institutions and accounts.
    static func makeAccountListViewModel() -> AccountListViewModel {
        seedInstitutionsAndAccounts()
        return AccountListViewModel(
            toasty: container.toasty,
            getInstitutions: container.getInstitutions,
            getAccounts: container.getAccounts,
            archiveAccount: container.archiveAccount,
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
            getInstitutions: container.getInstitutions,
            getAccounts: container.getAccounts,
            userId: container.userId,
            addAccountFormViewModel: container.makeAccountFormViewModel()
        )
    }

    /// - Returns: A TransactionListViewModel seeded with preview transactions.
    static func makeTransactionListViewModel() -> TransactionListViewModel {
        seedTransactions()
        return TransactionListViewModel(
            toasty: container.toasty,
            getTransactions: container.getTransactions,
            deleteTransaction: container.deleteTransaction,
            userId: container.userId
        )
    }
}
