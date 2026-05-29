//
//  TransferFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import SwiftUI
import CustomLabels

/// Form to create an internal transfer between two active accounts.
struct TransferFormView: View {

    @State var viewModel: TransferFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    EchoLedgerLoader().frame(width: 80, height: 80)
                } else {
                    Form {
                        Section("Comptes") {
                            Picker("De", selection: $viewModel.sourceAccount) {
                                Text("—").tag(Optional<Account>.none)
                                ForEach(viewModel.availableAccounts) { item in
                                    (Text(item.account.name) + Text(" • \(item.institutionName)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary))
                                        .tag(Optional(item.account))
                                }
                            }
                            Picker("Vers", selection: $viewModel.destinationAccount) {
                                Text("—").tag(Optional<Account>.none)
                                ForEach(viewModel.availableAccounts) { item in
                                    (Text(item.account.name) + Text(" • \(item.institutionName)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary))
                                        .tag(Optional(item.account))
                                }
                            }
                        }

                        Section("Montant") {
                            HStack {
                                TextField("0,00", value: $viewModel.amount, format: .number)
                                    .keyboardType(.decimalPad)
                                Text("€").foregroundStyle(.secondary)
                            }
                            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                        }

                        Section("Description (optionnel)") {
                            TextField("Ex : virement livret", text: $viewModel.label)
                        }

                        Section {
                            Button {
                                Task { await viewModel.submit() }
                            } label: {
                                CustomButtonLabel(
                                    iconLeading: "arrow.left.arrow.right",
                                    message: viewModel.isEditing ? "Modifier le transfert" : "Transférer",
                                    color: .accentColor,
                                    isSelected: viewModel.isValid
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(!viewModel.isValid)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Modifier le transfert" : "Transfert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess { dismiss() }
            }
            .task {
                await viewModel.loadAccounts()
            }
        }
    }
}

#Preview {
    TransferFormView(viewModel: PreviewHelpers.transferFormViewModel)
}
