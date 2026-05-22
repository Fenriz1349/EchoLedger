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

    init(transfer: Transfer, coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = State(wrappedValue: coordinator.makeTransferDetailViewModel(transfer: transfer))
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
                    LabeledContent("Montant", value: viewModel.transfer.amount.toEuro)
                    LabeledContent("Date", value: viewModel.transfer.date.formatted(date: .long, time: .omitted))
                    if !viewModel.transfer.label.isEmpty && viewModel.transfer.label != "Transfert" {
                        LabeledContent("Description", value: viewModel.transfer.label)
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        Button { viewModel.showEditForm = true } label: {
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
                    Task {
                        await viewModel.delete()
                        dismiss()
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Les deux transactions associées à ce transfert seront supprimées définitivement.")
            }
            .sheet(isPresented: $viewModel.showEditForm) {
                TransferFormView(
                    viewModel: coordinator.makeTransferFormViewModel(existing: viewModel.transfer)
                )
            }
            .onChange(of: viewModel.showEditForm) {
                if !viewModel.showEditForm { dismiss() }
            }
            .task {
                await viewModel.loadNames()
            }
        }
    }
}

#Preview {
    TransferDetailView(
        transfer: Transfer(source: PreviewData.transferExpense, destination: PreviewData.transferIncome),
        coordinator: PreviewHelpers.appCoordinator
    )
    .environment(PreviewHelpers.container)
}
