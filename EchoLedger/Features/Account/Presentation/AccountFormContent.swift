//
//  AccountFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

/// Form fields for creating or editing an account: name, category, initial balance,
/// institution selection, and archive/delete actions when editing.
struct AccountFormContent: View {

    @Bindable var viewModel: AccountFormViewModel

    var body: some View {
        Group {
            Section("Compte") {
                CustomTextField(
                    placeholder: "Nom du compte",
                    text: $viewModel.name,
                    type: .alphaNumber,
                    validator: viewModel.isValidName,
                    errorMessage: "Le nom doit contenir au moins 2 caractères.",
                    validationState: $viewModel.nameState,
                    colors: .echo,
                    showErrorOnlyWhenTriggered: false,
                    cornerRadius: .echoCorner,
                    hasShadow: false
                )
                .listRowInsets(EdgeInsets())
                .padding(.top)
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
                        CustomTextField(
                            placeholder: "0,00€",
                            text: $viewModel.initialBalanceText,
                            type: .decimal,
                            colors: .echo,
                            showErrorOnlyWhenTriggered: false,
                            cornerRadius: .echoCorner,
                            hasShadow: false
                        )
                        .onChange(of: viewModel.initialBalanceText) { viewModel.sanitizeBalance() }
                        SegmentedToggle(selection: $viewModel.isInitialBalanceExpense, style: .account)
                    }

                    DatePicker("Date", selection: $viewModel.initialBalanceDate, displayedComponents: .date)
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

            if viewModel.isEditing {
                Section {
                    SegmentedToggle(selection: $viewModel.isArchived, style: .archive) { target in
                        Task {
                            if target {
                                await viewModel.archive()
                            } else {
                                await viewModel.unarchive()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)

                    Button(role: .destructive) {
                        viewModel.showDeleteDialog = true
                    } label: {
                        CustomButtonLabel(iconLeading: "trash",
                                          message: "Supprimer le compte",
                                          color: .red,
                                          isSelected: false)
                    }
                    .disabled(viewModel.isLoading)
                    .confirmationDialog(
                        "Supprimer le compte ?",
                        isPresented: $viewModel.showDeleteDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Garder l'historique") {
                            viewModel.pendingDeleteMode = .keepHistory
                        }
                        Button("Tout supprimer", role: .destructive) {
                            viewModel.pendingDeleteMode = .everything
                        }
                        Button("Annuler", role: .cancel) {}
                    }
                    .alert(
                        "Confirmer la suppression",
                        isPresented: Binding(
                            get: { viewModel.pendingDeleteMode != nil },
                            set: { if !$0 { viewModel.pendingDeleteMode = nil } }
                        )
                    ) {
                        Button("Supprimer", role: .destructive) {
                            if let mode = viewModel.pendingDeleteMode {
                                Task { await viewModel.delete(mode: mode) }
                            }
                        }
                        Button("Annuler", role: .cancel) {
                            viewModel.pendingDeleteMode = nil
                        }
                    } message: {
                        switch viewModel.pendingDeleteMode {
                        case .everything:
                            Text("Le compte et toutes ses transactions seront définitivement supprimés. Cette action est irréversible.")
                        default:
                            Text("Le compte sera supprimé mais ses transactions resteront visibles dans l'historique.")
                        }
                    }
                }
            }
        }
        .task { await viewModel.loadInstitutions() }
        .listRowBackground(Color.echoCard)
    }
}

#Preview {
    Form {
        AccountFormContent(viewModel: PreviewHelpers.makeAccountFormViewModel())
    }
}
