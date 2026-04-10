//
//  TransactionFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct TransactionFormView: View {

    @State var viewModel: TransactionFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Montant") {
                    TextField("0,00", text: $viewModel.amount)
                        .keyboardType(.decimalPad)

                    Toggle("Dépense", isOn: $viewModel.isExpense)

                    Picker("Categorie", selection: $viewModel.category) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            Label(category.name, systemImage: category.icon).tag(category)
                        }
                    }
                }

                Section("Label") {
                    TextField("Optionnel", text: $viewModel.label)
                }

                Section("Compte") {
                    if viewModel.availableAccounts.isEmpty {
                        Text("Aucun compte disponible").foregroundStyle(.secondary)
                    } else {
                        AccountPickerView(
                            selectedAccount: $viewModel.selectedAccount,
                            availableAccounts: viewModel.availableAccounts
                        )
                        Button {
                            if let account = viewModel.selectedAccount {
                                viewModel.addSplit(for: account)
                            }
                        } label: {
                            Label("Ajouter un compte", systemImage: "plus")
                        }
                    }
                }

                if viewModel.splits.count > 1 {
                    Section("Répartition") {
                        let indexedSplits = Array(viewModel.splits.enumerated())
                        ForEach(indexedSplits, id: \.element.id) { index, _ in
                            SplitRowView(
                                index: index,
                                split: $viewModel.splits[index],
                                availableAccounts: viewModel.availableAccounts,
                                onDelete: { viewModel.removeSplit(at: index) }
                            )
                        }
                    }
                }

                Section("Notes") {
                    Text("À venir")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(viewModel.existingTransaction == nil ? "Nouvelle transaction" :"Modifier la transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.existingTransaction == nil ? "Ajouter" : "Modifier ") {
                        Task { await viewModel.submit() }
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
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
