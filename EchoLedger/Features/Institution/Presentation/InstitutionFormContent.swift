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
            CustomTextField(
                placeholder: "Nom de l'établissement",
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
            .accessibilityIdentifier("institutionField.name")

            Picker("Categorie", selection: $viewModel.category) {
                ForEach(InstitutionCategory.allCases, id: \.self) { category in
                    Label(category.name, systemImage: category.icon)
                        .tag(category)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("institutionField.category")

            Button {
                Task { await viewModel.submit() }
            } label: {
                CustomButtonLabel(
                    message: viewModel.isEditing ? "Modifier l'établissement" : "Ajouter l'établissement",
                    color: .accentColor,
                    isSelected: viewModel.isFormValid
                )
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            .accessibilityIdentifier("button.institutionSubmit")
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            if viewModel.isEditing {
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
                .padding(.horizontal, 4)

                Button(role: .destructive) {
                    viewModel.showDeleteDialog = true
                } label: {
                    CustomButtonLabel(
                        iconLeading: "trash",
                        message: "Supprimer l'établissement",
                        color: .red,
                        isSelected: false
                    )
                }
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier("button.deleteInstitution")
                .confirmationDialog(
                    "Supprimer l'établissement ?",
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
                        Text("L'établissement, tous ses comptes et toutes les transactions associées seront définitivement supprimés. Cette action est irréversible.")
                    default:
                        Text("L'établissement et ses comptes seront supprimés mais toutes les transactions resteront visibles dans l'historique.")
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color.echoCard)
        .clipShape(RoundedRectangle(cornerRadius: .echoCorner))
    }
}

#Preview {
    InstitutionFormContent(viewModel: PreviewHelpers.makeAddInstitutionFormViewModel())
        .environment(PreviewHelpers.container)
}
