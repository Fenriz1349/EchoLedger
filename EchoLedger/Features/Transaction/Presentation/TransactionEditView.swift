//
//  TransactionEditView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/06/2026.
//

import SwiftUI

/// Routes an existing transaction to the right editor: the dedicated initial balance form
/// for `.initialBalance`, the standard form otherwise. Single decision point so navigation
/// sites never have to branch themselves.
struct TransactionEditView: View {

    let transaction: Transaction
    let coordinator: AppCoordinator

    var body: some View {
        if transaction.category == .initialBalance {
            InitialBalanceFormView(viewModel: coordinator.makeTransactionFormViewModel(existing: transaction))
        } else {
            TransactionFormView(viewModel: coordinator.makeTransactionFormViewModel(existing: transaction))
        }
    }
}

#Preview {
    TransactionEditView(
        transaction: PreviewData.transactionRestaurant,
        coordinator: PreviewHelpers.appCoordinator
    )
    .environment(PreviewHelpers.container)
}
