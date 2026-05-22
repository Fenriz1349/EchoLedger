//
//  TransactionListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

/// Displays the full list of transactions with navigation to detail and swipe actions for delete and edit.
struct TransactionListView: View {

    let coordinator: AppCoordinator
    @State private var editTransaction: Transaction?

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.transactionListViewModel.isLoading {
                    EchoLedgerLoader()
                        .frame(width: 80, height: 80)
                } else if coordinator.transactionListViewModel.transactions.isEmpty {
                    Text("Aucune transaction pour le moment")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(coordinator.transactionListViewModel.listItems) { item in
                            TransactionListItemView(
                                item: item,
                                accountNames: coordinator.transactionListViewModel.accountNames,
                                onEdit: { editTransaction = $0 },
                                onDelete: { transaction in
                                    Task { await coordinator.transactionListViewModel.delete(transaction) }
                                },
                                onDeleteTransfer: { expense, income in
                                    Task { await coordinator.transactionListViewModel.deleteTransfer(expense: expense, income: income) }
                                }
                            )
                        }
                    }
                    .refreshable {
                        await coordinator.transactionListViewModel.load()
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction, coordinator: coordinator)
                    .onDisappear {
                        Task { await coordinator.transactionListViewModel.load() }
                    }
            }
            .sheet(item: $editTransaction) { transaction in
                TransactionFormView(
                    viewModel: coordinator.makeTransactionFormViewModel(existing: transaction)
                )
            }
            .onChange(of: editTransaction) {
                if editTransaction == nil {
                    Task { await coordinator.transactionListViewModel.load() }
                }
            }
            .task {
                await coordinator.transactionListViewModel.load()
            }
        }
    }
}

#Preview {
    TransactionListView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
