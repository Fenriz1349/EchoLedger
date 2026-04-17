//
//  TransactionFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

/// Modal form for creating or editing a transaction, including splits across multiple accounts.
struct TransactionFormView: View {

    @State var viewModel: TransactionFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TransactionFormContent(viewModel: viewModel)
            }
            .navigationTitle(viewModel.existingTransaction == nil ? "Nouvelle transaction" :"Modifier la transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .task {
                await viewModel.loadAccounts()
            }
            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess { dismiss() }
            }
        }
    }
}

#Preview {
    TransactionFormView(viewModel: PreviewHelpers.makeTransactionFormViewModel())
        .environment(PreviewHelpers.container)
}
