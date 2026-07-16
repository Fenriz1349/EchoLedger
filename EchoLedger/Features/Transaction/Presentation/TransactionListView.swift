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
    @State private var selectedTransaction: Transaction?
    @State private var selectedTransfer: Transfer?
    @State private var editTransfer: Transfer?

    var body: some View {
        NavigationStack {
            List {
                ForEach(coordinator.transactionListViewModel.sections) { section in
                    Section(section.title) {
                        ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                            TransactionListItemView(
                                item: item,
                                accountNames: coordinator.transactionListViewModel.accountNames,
                                onEdit: { editTransaction = $0 },
                                onDelete: { transaction in
                                    Task { await coordinator.transactionListViewModel.delete(transaction) }
                                },
                                onTap: { selectedTransaction = $0 },
                                onTapTransfer: { transfer in
                                    selectedTransfer = transfer
                                },
                                onDeleteTransfer: { transfer in
                                    Task { await coordinator.transactionListViewModel.deleteTransfer(transfer) }
                                },
                                onEditTransfer: { editTransfer = $0 }
                            )
                            .cascadeRow(index: index)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .echoRowStyle()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .contentMargins(.bottom, 72, for: .scrollContent)
            .scrollBounceBehavior(.always)
            .overlay {
                if coordinator.transactionListViewModel.transactions.isEmpty {
                    Text("Aucune transaction pour le moment")
                        .foregroundStyle(.secondary)
                }
            }
            .overlay(alignment: .bottom) {
                if !coordinator.transactionListViewModel.transactions.isEmpty {
                    TransactionFilterBar(viewModel: coordinator.transactionListViewModel)
                }
            }
            .refreshable {
                await coordinator.transactionListViewModel.refresh()
            }
            .searchable(
                text: Bindable(coordinator.transactionListViewModel).searchText,
                prompt: "Rechercher une transaction"
            )
            .echoBackground()
            .navigationTitle("Transactions")
            .navigationDestination(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction, coordinator: coordinator)
            }
            .onChange(of: selectedTransaction) {
                if selectedTransaction == nil {
                    Task { await coordinator.loadData() }
                }
            }
            .sheet(item: $editTransaction) { transaction in
                TransactionEditView(transaction: transaction, coordinator: coordinator)
            }
            .onChange(of: editTransaction) {
                if editTransaction == nil {
                    Task { await coordinator.loadData() }
                }
            }
            .navigationDestination(item: $selectedTransfer) { transfer in
                TransferDetailView(transfer: transfer, coordinator: coordinator)
            }
            .onChange(of: selectedTransfer) {
                if selectedTransfer == nil {
                    Task { await coordinator.loadData() }
                }
            }
            .sheet(item: $editTransfer) { transfer in
                TransferFormView(viewModel: coordinator.makeTransferFormViewModel(existing: transfer))
            }
            .onChange(of: editTransfer) {
                if editTransfer == nil {
                    Task { await coordinator.loadData() }
                }
            }
        }
        .overlay {
            if coordinator.transactionListViewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    TransactionListView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
