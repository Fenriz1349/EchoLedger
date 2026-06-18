//
//  AppCoordinator.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Owns all ViewModels and coordinates navigation for the application.
@MainActor
@Observable
final class AppCoordinator {

    let dashboardViewModel: DashboardViewModel
    let transactionListViewModel: TransactionListViewModel
    let accountListViewModel: AccountListViewModel
    let userProfileViewModel: UserProfileViewModel

    #if !CLOUD_TARGET
    var syncManager: SyncManager { container.syncManager }
    #endif
    var authSession: AuthSession { container.authSession }

    private let container: DIContainer

    /// - Parameters:
    ///   - container: The dependency injection container providing all use cases.
    ///   - user: The loaded user profile.
    ///   - onSignOut: Closure called when the user signs out or deletes their account.
    ///   - onSessionUpdated: Closure called when the user links an anonymous account.
    init(
        container: DIContainer,
        user: User,
        onSignOut: @escaping () -> Void,
        onSessionUpdated: @escaping (AuthSession) -> Void
    ) {
        self.container = container
        self.dashboardViewModel = container.makeDashboardViewModel()
        self.transactionListViewModel = container.makeTransactionListViewModel()
        self.accountListViewModel = container.makeAccountListViewModel()
        self.userProfileViewModel = container.makeUserProfileViewModel(
            user: user,
            onSignOut: onSignOut,
            onSessionUpdated: onSessionUpdated
        )
    }

    /// Loads the transaction-dependent view models — the transaction list, account balances
    /// and dashboard charts. Called once at launch to pre-fill the tabs, and again after a
    /// transaction is added or edited from the global form (those tabs stay alive in the
    /// TabView so their content won't reload on its own, and no single feature view model
    /// owns the global add button).
    func loadData() async {
        await transactionListViewModel.load()
        await accountListViewModel.load()
        await dashboardViewModel.load()
    }

    /// - Parameter account: The account to display in detail.
    /// - Returns: A configured AccountDetailViewModel.
    func makeAccountDetailViewModel(account: Account) -> AccountDetailViewModel {
        container.makeAccountDetailViewModel(account: account)
    }

    /// - Parameters:
    ///   - existing: An optional institution to pre-fill the form for editing.
    ///   - onAdd: Callback invoked with the newly created institution in creation mode.
    /// - Returns: A configured InstitutionFormViewModel.
    func makeInstitutionFormViewModel(
        existing: Institution? = nil,
        onAdd: @escaping (Institution) -> Void = { _ in }
    ) -> InstitutionFormViewModel {
        container.makeInstitutionFormViewModel(existing: existing, onAdd: onAdd)
    }

    /// - Parameter existing: An optional account to pre-fill the form for editing.
    /// - Returns: A configured AccountFormViewModel.
    func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        container.makeAccountFormViewModel(existing: existing)
    }

    /// - Parameter transfer: The transfer to display.
    /// - Returns: A configured TransferDetailViewModel.
    func makeTransferDetailViewModel(transfer: Transfer) -> TransferDetailViewModel {
        container.makeTransferDetailViewModel(transfer: transfer)
    }

    /// - Parameter existing: An optional transfer to pre-fill the form for editing.
    /// - Returns: A configured TransferFormViewModel.
    func makeTransferFormViewModel(existing: Transfer? = nil) -> TransferFormViewModel {
        container.makeTransferFormViewModel(existing: existing)
    }

    /// - Parameter existing: An optional transaction to pre-fill the form for editing.
    /// - Returns: A configured TransactionFormViewModel.
    func makeTransactionFormViewModel(existing: Transaction? = nil) -> TransactionFormViewModel {
        container.makeTransactionFormViewModel(existing: existing)
    }

    /// - Parameter transaction: The transaction whose attachment should be displayed.
    /// - Returns: The DocumentResult describing its attachment.
    func transactionDocument(for transaction: Transaction) -> DocumentResult {
        container.getTransactionDocument.execute(transaction: transaction)
    }
}
