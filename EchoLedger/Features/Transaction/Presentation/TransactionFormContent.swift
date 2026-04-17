//
//  TransactionFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomLabels

struct TransactionFormContent: View {

    @Bindable var viewModel: TransactionFormViewModel

    var body: some View {
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
            Button {
                withAnimation { viewModel.showAddAccountForm.toggle() }
            } label: {
                Label(
                    viewModel.showAddAccountForm ? "Annuler" : "Nouveau compte",
                    systemImage: viewModel.showAddAccountForm ? "xmark" : "plus"
                )
            }
        }

        if viewModel.showAddAccountForm {
            AccountFormContent(viewModel: viewModel.addAccountFormViewModel)
                .scrollDisabled(true)
                .listRowInsets(EdgeInsets())
                .onChange(of: viewModel.addAccountFormViewModel.isSuccess) {
                    if viewModel.addAccountFormViewModel.isSuccess {
                        viewModel.showAddAccountForm = false
                        Task { await viewModel.loadAccounts() }
                    }
                }
        }

        if viewModel.splits.count > 1 {
            Section("Répartition") {
                ForEach($viewModel.splits) { $split in
                    SplitRowView(
                        split: $split,
                        availableAccounts: viewModel.availableAccounts,
                        onDelete: {
                            if let index = viewModel.splits.firstIndex(where: { $0.id == split.id }) {
                                viewModel.removeSplit(at: index)
                            }
                        }
                    )
                }
            }
        }

        Section("Notes") {
            Text("À venir")
                .foregroundStyle(.secondary)
                .font(.footnote)
        }
        
        Button {
            Task { await viewModel.submit() }
        } label: {
            CustomButtonLabel(
                message: viewModel.existingTransaction == nil
                ? "Ajouter la transaction"
                : "Modifier la transaction",
                color: .accentColor,
                isSelected: viewModel.isValid
            )
        }
        .disabled(!viewModel.isValid || viewModel.isLoading)

        if let errorMessage = viewModel.errorMessage {
            Section {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    Form{
        TransactionFormContent(viewModel: PreviewHelpers.makeTransactionFormViewModel())
    }
}
