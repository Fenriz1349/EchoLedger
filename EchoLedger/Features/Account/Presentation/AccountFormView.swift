//
//  AccountFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

struct AccountFormView: View {

    @State var viewModel: AccountFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Compte") {
                    CustomTextField.immediate(
                        placeholder: "Nom du compte",
                        text: $viewModel.name,
                        type: .alphaNumber,
                        validator: { $0.trimmingCharacters(in: .whitespaces).count >= 2 },
                        errorMessage: "Le nom doit contenir au moins 2 caractères"
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
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Nouveau compte")
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
                await viewModel.loadInstitutions()
            }
            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess { dismiss() }
            }
        }
    }
}

#Preview {
    AccountFormView(viewModel: PreviewHelpers.makeAddAccountViewModel())
        .environment(PreviewHelpers.container)
}
