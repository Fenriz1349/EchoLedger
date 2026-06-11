//
//  TransactionDetailView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomLabels

/// Shows the full details of a transaction, with actions to edit or delete it.
struct TransactionDetailView: View {

    let transaction: Transaction
    let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showEditForm = false

    init(transaction: Transaction, coordinator: AppCoordinator) {
        self.transaction = transaction
        self.coordinator = coordinator
    }

    private var currentTransaction: Transaction {
        coordinator.transactionListViewModel.transactions.first { $0.id == transaction.id } ?? transaction
    }

    var body: some View {
        List {
            Section("Informations") {
                LabeledContent("Label", value: currentTransaction.label)
                LabeledContent("Montant", value: currentTransaction.totalAmount.toEuro)
                LabeledContent("Date", value: currentTransaction.date.formatted(date: .long, time: .omitted))
                HStack {
                    Text("Catégorie")
                    Spacer()
                    Label(currentTransaction.category.name, systemImage: currentTransaction.category.icon)
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Type", value: currentTransaction.isExpense ? "Dépense" : "Revenu")
            }

            if !currentTransaction.splits.isEmpty {
                Section("Répartition") {
                    ForEach(currentTransaction.splits) { split in
                        SplitRowView(
                            amount: split.amount,
                            accountName: coordinator.transactionListViewModel.accountNames[split.accountId],
                            institutionName: coordinator.transactionListViewModel.institutionNames[split.accountId]
                        )
                    }
                }
            }

            if currentTransaction.attachmentURL != nil {
                Section("Justificatif") {
                    DocumentDisplayView(document: coordinator.transactionDocument(for: currentTransaction))
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

        }
        .navigationTitle(currentTransaction.label)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showEditForm = true } label: {
                    Image(systemName: "pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    Task {
                        await coordinator.transactionListViewModel.delete(currentTransaction)
                        dismiss()
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
        }
        .task(id: currentTransaction.id) {
            await coordinator.transactionListViewModel.loadAccountNames(for: currentTransaction)
        }
        .sheet(isPresented: $showEditForm) {
            TransactionEditView(transaction: currentTransaction, coordinator: coordinator)
        }
        .onChange(of: showEditForm) {
            if !showEditForm {
                Task { await coordinator.transactionListViewModel.load() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(
            transaction: PreviewData.transactionRestaurant,
            coordinator: PreviewHelpers.appCoordinator
        )
    }
    .environment(PreviewHelpers.container)
}
