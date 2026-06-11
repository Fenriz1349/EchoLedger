//
//  InstitutionFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

/// Form for creating or editing an institution.
/// In creation mode, displayed inline inside AccountFormView.
/// In edit mode, presented as a sheet from AccountListView.
struct InstitutionFormContent: View {

    @Bindable var viewModel: InstitutionFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CustomTextField.immediate(
                placeholder: "Nom de l'établissement",
                text: $viewModel.name,
                type: .alphaNumber,
                validator: { $0.trimmingCharacters(in: .whitespaces).count >= 2 },
                errorMessage: "Le nom doit contenir au moins 2 caractères",
                colors: .echo
            )

            Picker("Categorie", selection: $viewModel.category) {
                ForEach(InstitutionCategory.allCases, id: \.self) { category in
                    Label(category.name, systemImage: category.icon)
                        .tag(category)
                }
            }
            .pickerStyle(.menu)

            Button {
                Task { await viewModel.submit() }
            } label: {
                CustomButtonLabel(
                    message: viewModel.isEditing ? "Modifier l'établissement" : "Ajouter l'établissement",
                    color: .accentColor,
                    isSelected: viewModel.isValid
                )
            }
            .disabled(!viewModel.isValid || viewModel.isLoading)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            if viewModel.isEditing {
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
                .padding(.horizontal, 4)

                Button(role: .destructive) {
                    viewModel.showDeleteAlert = true
                } label: {
                    CustomButtonLabel(
                        iconLeading: "trash",
                        message: "Supprimer l'établissement",
                        color: .red,
                        isSelected: false
                    )
                }
                .disabled(viewModel.isLoading)
                .alert("Supprimer l'établissement ?", isPresented: $viewModel.showDeleteAlert) {
                    Button("Supprimer", role: .destructive) {
                        Task { await viewModel.delete() }
                    }
                    Button("Annuler", role: .cancel) {}
                } message: {
                    Text("L'établissement, tous ses comptes et toutes les transactions associées seront définitivement supprimés. Cette action est irréversible.")
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    InstitutionFormContent(viewModel: PreviewHelpers.makeAddInstitutionFormViewModel())
        .environment(PreviewHelpers.container)
}
