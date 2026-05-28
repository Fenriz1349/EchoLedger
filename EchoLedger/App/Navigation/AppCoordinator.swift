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

    #if !CLOUD_TARGET
    var syncManager: SyncManager { container.syncManager }
    #endif
    var authSession: AuthSession { container.authSession }

    private let container: DIContainer
    private let onSignOut: () -> Void

    /// - Parameters:
    ///   - container: The dependency injection container providing all use cases.
    ///   - onSignOut: Closure called after a successful sign-out or account deletion.
    init(container: DIContainer, onSignOut: @escaping () -> Void) {
        self.container = container
        self.onSignOut = onSignOut
        self.dashboardViewModel = container.makeDashboardViewModel()
        self.transactionListViewModel = container.makeTransactionListViewModel()
        self.accountListViewModel = container.makeAccountListViewModel()
    }

    /// Creates a UserProfileViewModel with sign-out and session-update callbacks.
    /// - Returns: A configured UserProfileViewModel.
    func makeUserProfileViewModel() -> UserProfileViewModel {
        container.makeUserProfileViewModel(
            onSignOut: { [weak self] in self?.signOut() },
            onSessionUpdated: { [weak self] session in self?.updateSession(session) }
        )
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

    /// Updates the current auth session, used after linking an anonymous account.
    /// - Parameter session: The updated authentication session.
    func updateSession(_ session: AuthSession) {
        container.authSession = session
    }

    /// Triggers the sign-out flow, resetting the app to the authentication screen.
    func signOut() {
        onSignOut()
    }
}
