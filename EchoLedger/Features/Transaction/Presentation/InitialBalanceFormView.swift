//
//  InitialBalanceFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/06/2026.
//

import SwiftUI
import CustomLabels

/// Dedicated editor for an account's initial balance transaction.
/// Reuses TransactionFormViewModel so the whole transaction is updated (no data loss),
/// while exposing only the amount and its sign — category and account stay fixed.
struct InitialBalanceFormView: View {

    @State var viewModel: TransactionFormViewModel
    @State private var amountText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Solde initial") {
                    if let accountLabel = viewModel.initialBalanceAccountLabel {
                        LabeledContent("Compte", value: accountLabel)
                    }
                    HStack {
                        Text(viewModel.isExpense ? "-" : "")
                        TextField("0,00€", text: $amountText)
                            .keyboardType(.decimalPad)
                            .onChange(of: amountText) { _, newValue in
                                let filtered = newValue.numericOnly
                                if filtered != newValue {
                                    amountText = filtered
                                }
                                viewModel.setInitialBalanceAmount(filtered.toDouble)
                            }
                        Text(viewModel.isExpense ? "Négatif" : "Positif")
                        Toggle("", isOn: $viewModel.isExpense)
                            .labelsHidden()
                            .tint(.red)
                    }
                }
                .listRowBackground(Color.echoCard)

                Button {
                    Task { await viewModel.submit() }
                } label: {
                    CustomButtonLabel(message: "Modifier", color: .accentColor, isSelected: viewModel.isFormValid)
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Solde initial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .task {
                await viewModel.loadAccounts()
            }
            .onAppear {
                amountText = viewModel.initialBalanceAmount == 0 ? "" : String(viewModel.initialBalanceAmount)
            }
            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess { dismiss() }
            }
            .echoBackground()
        }
    }
}

#Preview {
    InitialBalanceFormView(viewModel: PreviewHelpers.makeTransactionFormViewModel())
        .environment(PreviewHelpers.container)
}
