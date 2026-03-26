//
//  AddAccountView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

struct AddAccountView: View {
    
    @State var viewModel: AddAccountViewModel
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
                    
                    Picker("Type", selection: $viewModel.type) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Label(type.name, systemImage: type.icon).tag(type)
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
                                Label(institution.name, systemImage: institution.type.icon)
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
    let container = DIContainer.preview()
    return AddAccountView(viewModel: container.makeAddAccountViewModel())
        .environment(container)
}
