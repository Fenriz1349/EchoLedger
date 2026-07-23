//
//  TransactionFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomLabels
import CustomTextFields

/// Form body for creating or editing a transaction: splits, category, date, label, and attachment.
/// Embedded in `TransactionFormView`'s `Form` so it can share the same scroll container.
struct TransactionFormContent: View {

    @Bindable var viewModel: TransactionFormViewModel

    var body: some View {
        Section("Montant") {
            if viewModel.availableAccounts.isEmpty {
                Text("Aucun comptes disponibles")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($viewModel.splits) { $split in
                    SplitFormContent(
                        split: $split,
                        availableAccounts: viewModel.accountOptions(forSplit: split.id),
                        onDelete: viewModel.splits.count > 1 ? {
                            if let index = viewModel.splits.firstIndex(where: { $0.id == split.id }) {
                                viewModel.removeSplit(at: index)
                            }
                        } : nil
                    )
                }

                if viewModel.splits.count > 1 {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(viewModel.totalAmount.toEuro)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
        }

        Section {
            HStack {
                Button {
                    if let account = viewModel.nextAvailableAccount {
                        viewModel.addSplit(for: account)
                    }
                } label: {
                    Label("Split", systemImage: "plus")
                }
                .buttonStyle(.borderless)
                .disabled(viewModel.nextAvailableAccount == nil)

                Spacer()

                Button {
                    withAnimation { viewModel.showAddAccountForm.toggle() }
                } label: {
                    Label(
                        viewModel.showAddAccountForm ? "Annuler" : "Nouveau compte",
                        systemImage: viewModel.showAddAccountForm ? "xmark" : "plus"
                    )
                }
                .buttonStyle(.borderless)
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

        Section("Détails") {
            Picker(selection: $viewModel.category) {
                ForEach(viewModel.categoryList, id: \.self) { category in
                    Label(category.name, systemImage: category.icon).tag(category)
                }
            } label: {
                Label("Catégorie", systemImage: viewModel.category.icon)
            }

            SegmentedToggle(selection: $viewModel.isIncome, style: .transaction)

            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
        }

        Section("Libellé (optionnel)") {
            CustomTextField(
                placeholder: "Ex : Boulangerie, vettement...",
                text: $viewModel.label,
                type: .alphaNumber,
                colors: .echo,
                cornerRadius: .echoCorner,
                hasShadow: false
            )
        }

        TransactionAttachmentSection(viewModel: viewModel)

        Button {
            Task { await viewModel.submit() }
        } label: {
            CustomButtonLabel(
                message: viewModel.existingTransaction == nil
                ? "Ajouter la transaction"
                : "Modifier la transaction",
                color: .accentColor,
                isSelected: viewModel.isFormValid
            )
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

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
    Form {
        TransactionFormContent(viewModel: PreviewHelpers.makeTransactionFormViewModel())
    }
}
