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
                    AddInstitutionFormView(viewModel: viewModel.addInstitutionFormViewModel)
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
                    message: viewModel.existingAccount == nil
                    ? "Ajouter le compte"
                    : "Modifier le compte",
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
        .task { await viewModel.loadInstitutions() }
    }
}

#Preview {
    Form {
        AccountFormContent(viewModel: PreviewHelpers.makeccountFormViewModel())
    }
}
