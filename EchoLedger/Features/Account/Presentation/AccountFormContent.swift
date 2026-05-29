//
//  AccountFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

struct AccountFormContent: View {

    @Bindable var viewModel: AccountFormViewModel

    var body: some View {
        Group {
            Section("Compte") {
                CustomTextField.immediate(
                    placeholder: "Nom du compte",
                    text: $viewModel.name,
                    type: .alphaNumber,
                    validator: { $0.trimmingCharacters(in: .whitespaces).count >= 2 },
                    errorMessage: "Le nom doit contenir au moins 2 caractères",
                    colors: .echo
                )
                .listRowInsets(EdgeInsets())
                .padding(.horizontal)

                Picker("Categorie", selection: $viewModel.category) {
                    ForEach(AccountCategory.allCases, id: \.self) { category in
                        Label(category.name, systemImage: category.icon).tag(category)
                    }
                }
            }

            if viewModel.existingAccount == nil {
                Section("Solde initial") {
                    HStack {
                        Text(viewModel.isInitialBalanceExpense ? "-" : "")
                        TextField("0,00€", text: $viewModel.initialBalanceText)
                            .keyboardType(.decimalPad)
                        Toggle("", isOn: $viewModel.isInitialBalanceExpense)
                            .labelsHidden()
                            .tint(.red)
                    }
                }
            }

            Section("Établissement") {
                if viewModel.institutions.isEmpty {
                    Text("Aucun établissement — créez-en un ci-dessous")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                } else {
                    Picker("Établissement", selection: $viewModel.selectedInstitution) {
                        ForEach(viewModel.institutions) { institution in
                            Label(institution.name, systemImage: institution.category.icon)
                                .tag(Optional(institution))
                        }
                    }
                }

                Button {
                    withAnimation { viewModel.showAddInstitutionForm.toggle() }
                } label: {
                    Label(
                        viewModel.showAddInstitutionForm ? "Annuler" : "Nouvel établissement",
                        systemImage: viewModel.showAddInstitutionForm ? "xmark" : "plus"
                    )
                }

                if viewModel.showAddInstitutionForm {
                    InstitutionFormContent(viewModel: viewModel.addInstitutionFormViewModel)
                        .listRowInsets(EdgeInsets())
                        .onChange(of: viewModel.addInstitutionFormViewModel.isSuccess) {
                            if viewModel.addInstitutionFormViewModel.isSuccess {
                                viewModel.showAddInstitutionForm = false
                            }
                        }
                }
            }

            Button {
                Task { await viewModel.submit() }
            } label: {
                CustomButtonLabel(
                    message: viewModel.existingAccount == nil ? "Ajouter le compte" : "Modifier le compte",
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

            if viewModel.isEditing {
                Section {
                    Toggle(viewModel.isArchived ? "Archivé" : "Actif", isOn: Binding(
                        get: { viewModel.isArchived },
                        set: { isArchived in
                            Task {
                                if isArchived {
                                    await viewModel.archive()
                                } else {
                                    await viewModel.unarchive()
                                }
                            }
                        }
                    ))
                    .disabled(viewModel.isLoading)

                    Button(role: .destructive) {
                        viewModel.showDeleteAlert = true
                    } label: {
                        Label("Supprimer le compte", systemImage: "trash")
                    }
                    .disabled(viewModel.isLoading)
                    .alert("Supprimer le compte ?", isPresented: $viewModel.showDeleteAlert) {
                        Button("Supprimer", role: .destructive) {
                            Task { await viewModel.delete() }
                        }
                        Button("Annuler", role: .cancel) {}
                    } message: {
                        Text("Le compte et toutes ses transactions seront définitivement supprimés. Cette action est irréversible.")
                    }
                }
            }
        }
        .task { await viewModel.loadInstitutions() }
    }
}

#Preview {
    Form {
        AccountFormContent(viewModel: PreviewHelpers.makeAccountFormViewModel())
    }
}
