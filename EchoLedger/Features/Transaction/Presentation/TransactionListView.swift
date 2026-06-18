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
    @State private var selectedTransfer: Transfer?
    @State private var editTransfer: Transfer?

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.transactionListViewModel.transactions.isEmpty {
                    Text("Aucune transaction pour le moment")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(coordinator.transactionListViewModel.sections) { section in
                            Section(section.title) {
                                ForEach(section.items) { item in
                                    TransactionListItemView(
                                        item: item,
                                        accountNames: coordinator.transactionListViewModel.accountNames,
                                        onEdit: { editTransaction = $0 },
                                        onDelete: { transaction in
                                            Task { await coordinator.transactionListViewModel.delete(transaction) }
                                        },
                                        onTapTransfer: { transfer in
                                            selectedTransfer = transfer
                                        },
                                        onDeleteTransfer: { transfer in
                                            Task { await coordinator.transactionListViewModel.deleteTransfer(transfer) }
                                        },
                                        onEditTransfer: { editTransfer = $0 }
                                    )
                                }
                            }
                        }
                    }
                    .contentMargins(.bottom, 72, for: .scrollContent)
                    .overlay(alignment: .bottom) {
                        TransactionFilterBar(viewModel: coordinator.transactionListViewModel)
                    }
                    .refreshable {
                        await coordinator.transactionListViewModel.refresh()
                    }
                }
            }
            .searchable(
                text: Bindable(coordinator.transactionListViewModel).searchText,
                prompt: "Rechercher une transaction"
            )
            .navigationTitle("Transactions")
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction, coordinator: coordinator)
                    .onDisappear {
                        Task { await coordinator.transactionListViewModel.load() }
                    }
            }
            .sheet(item: $editTransaction) { transaction in
                TransactionEditView(transaction: transaction, coordinator: coordinator)
            }
            .onChange(of: editTransaction) {
                if editTransaction == nil {
                    Task { await coordinator.transactionListViewModel.load() }
                }
            }
            .navigationDestination(item: $selectedTransfer) { transfer in
                TransferDetailView(transfer: transfer, coordinator: coordinator)
            }
            .onChange(of: selectedTransfer) {
                if selectedTransfer == nil {
                    Task { await coordinator.transactionListViewModel.load() }
                }
            }
            .sheet(item: $editTransfer) { transfer in
                TransferFormView(viewModel: coordinator.makeTransferFormViewModel(existing: transfer))
            }
            .onChange(of: editTransfer) {
                if editTransfer == nil {
                    Task { await coordinator.transactionListViewModel.load() }
                }
            }
        }
        .overlay {
            if coordinator.transactionListViewModel.isRefreshing {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    TransactionListView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
