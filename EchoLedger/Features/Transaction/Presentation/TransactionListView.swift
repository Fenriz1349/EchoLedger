//
//  TransactionListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

/// Displays the full list of transactions with navigation to detail and swipe actions for delete and edit.
struct TransactionListView: View {

    @Environment(DIContainer.self) private var container
    let coordinator: AppCoordinator
    @State private var editTransaction: Transaction?

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.transactionListViewModel.isLoading {
                    ProgressView()
                } else if coordinator.transactionListViewModel.transactions.isEmpty {
                    Text("Aucune transaction pour le moment")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(coordinator.transactionListViewModel.transactions, id: \.id) { item in
                            NavigationLink(value: item) {
                                HStack {
                                    let name = item.category.icon
                                    Image(systemName: name)
                                        .frame(width: 32)

                                    VStack(alignment: .leading) {
                                        Text(item.label)
                                            .font(.body)
                                        Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Text(item.totalAmount.toEuro)
                                        .foregroundStyle(item.isExpense ? Color.primary : Color.green)
                                        .fontWeight(item.isExpense ? .regular : .semibold)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await coordinator.transactionListViewModel.delete(item) }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                                Button {
                                    editTransaction = item
                                } label: {
                                    Label("Modifier", systemImage: "pencil")
                                }
                            }
                        }
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
