//
//  TransferDetailView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import SwiftUI
import CustomLabels

/// Shows the full details of a transfer: accounts, amount, date, and description.
/// Inline buttons to edit or delete the transfer, matching the layout of `TransactionDetailView`.
struct TransferDetailView: View {

    @State private var viewModel: TransferDetailViewModel
    let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showEditForm = false

    init(expense: Transaction, income: Transaction, coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = State(wrappedValue: coordinator.makeTransferDetailViewModel(expense: expense, income: income))
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Transfert") {
                    HStack {
                        Text(viewModel.sourceName)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(viewModel.destinationName)
                    }
                    LabeledContent("Montant", value: viewModel.expense.totalAmount.toEuro)
                    LabeledContent(
                        "Date",
                        value: viewModel.expense.date.formatted(date: .long, time: .omitted)
                    )
                    if !viewModel.expense.label.isEmpty && viewModel.expense.label != "Transfert" {
                        LabeledContent("Description", value: viewModel.expense.label)
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        Button { showEditForm = true } label: {
                            CustomButtonLabel(iconLeading: "pencil", message: "Modifier", color: .blue)
                        }
                        .buttonStyle(.plain)

                        Button { viewModel.showDeleteAlert = true } label: {
                            CustomButtonLabel(iconLeading: "trash", message: "Supprimer", color: .red)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Transfert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .alert("Supprimer ce transfert ?", isPresented: $viewModel.showDeleteAlert) {
                Button("Supprimer", role: .destructive) {
                    Task { await viewModel.delete() }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Les deux transactions associées à ce transfert seront supprimées définitivement.")
            }
            .sheet(isPresented: $showEditForm) {
                TransferFormView(
                    viewModel: coordinator.makeTransferFormViewModel(
                        existingExpense: viewModel.expense,
                        existingIncome: viewModel.income
                    )
                )
            }
            .onChange(of: viewModel.isDeleted) {
                if viewModel.isDeleted { dismiss() }
            }
            .onChange(of: showEditForm) {
                if !showEditForm { dismiss() }
            }
            .task { await viewModel.load() }
        }
    }
}

#Preview {
    TransferDetailView(
        expense: PreviewData.transferExpense,
        income: PreviewData.transferIncome,
        coordinator: PreviewHelpers.appCoordinator
    )
    .environment(PreviewHelpers.container)
}
