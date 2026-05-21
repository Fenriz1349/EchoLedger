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

    let transactionListViewModel: TransactionListViewModel
    let accountListViewModel: AccountListViewModel

    private let container: DIContainer
    private let onSignOut: () -> Void

    /// - Parameters:
    ///   - container: The dependency injection container providing all use cases.
    ///   - onSignOut: Closure called after a successful sign-out or account deletion.
    init(container: DIContainer, onSignOut: @escaping () -> Void) {
        self.container = container
        self.onSignOut = onSignOut
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

    /// - Parameter existing: An optional account to pre-fill the form for editing.
    /// - Returns: A configured AccountFormViewModel.
    func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        container.makeAccountFormViewModel(existing: existing)
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
