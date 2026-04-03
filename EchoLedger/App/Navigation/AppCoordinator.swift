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

    init(container: DIContainer) {
        self.container = container

        self.transactionListViewModel = container.makeTransactionListViewModel()
        self.accountListViewModel = container.makeAccountListViewModel()
    }

    func makeTransactionFormViewModel(existing: Transaction? = nil) -> TransactionFormViewModel {
        let viewModel = container.makeTransactionFormViewModel()
        viewModel.existingTransaction = existing
        return viewModel
    }
}
