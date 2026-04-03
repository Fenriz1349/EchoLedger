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
                        Text("Aucun compte disponible")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Compte", selection: $viewModel.selectedAccount) {
                            ForEach(viewModel.availableAccounts, id: \.account.id) { item in
                                Text("\(item.institution.name) — \(item.account.name)")
                                    .tag(Optional(item.account))
                            }
                        }

                        if let account = viewModel.selectedAccount {
                            Button {
                                viewModel.addSplit(for: account)
                            } label: {
                                Label("Ajouter un compte", systemImage: "plus")
                            }
                        }
                    }
                }

                if viewModel.splits.count > 1 {
                    Section("Répartition") {
                        ForEach(Array(viewModel.splits.enumerated()), id: \.element.id) { index, split in
                            HStack {
                                Text(viewModel.accountNames[split.accountId] ?? "Compte inconnu")
                                Spacer()
                                Text("\(split.amount)")
                                    .foregroundStyle(.secondary)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeSplit(at: index)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
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
            .navigationTitle("Nouvelle transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
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
