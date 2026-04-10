//
//  TransactionDetailView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomLabels

struct TransactionDetailView: View {

    let transaction: Transaction
    let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showEditForm = false

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
                        LabeledContent(split.id.uuidString, value: split.amount.toEuro)
                    }
                }
            }
            Section {
                HStack(spacing: 12) {
                    Button {
                        showEditForm = true
                    } label: {
                        CustomButtonLabel(
                            iconLeading: "pencil",
                            message: "Modifier",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                    Button {
                        Task {
                            await coordinator.transactionListViewModel.delete(currentTransaction)
                            dismiss()
                        }
                    } label: {
                        CustomButtonLabel(
                            iconLeading: "trash",
                            message: "Supprimer",
                            color: .red
                        )
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal)
            }
        }
        .navigationTitle(currentTransaction.label)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditForm) {
            TransactionFormView(viewModel: coordinator.makeTransactionFormViewModel(existing: currentTransaction))
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
