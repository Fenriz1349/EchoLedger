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

    /// - Parameter container: The dependency injection container providing all use cases.
    init(container: DIContainer) {
        self.container = container

        self.transactionListViewModel = container.makeTransactionListViewModel()
        self.accountListViewModel = container.makeAccountListViewModel()
    }

    /// - Parameter existing: An optional transaction to pre-fill the form for editing.
    /// - Returns: A configured TransactionFormViewModel.
    func makeTransactionFormViewModel(existing: Transaction? = nil) -> TransactionFormViewModel {
        container.makeTransactionFormViewModel(existing: existing)
    }

    /// - Parameter existing: An optional account to pre-fill the form for editing.
    /// - Returns: A configured AccountFormViewModel.
    func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        container.makeAccountFormViewModel(existing: existing)
    }
}
