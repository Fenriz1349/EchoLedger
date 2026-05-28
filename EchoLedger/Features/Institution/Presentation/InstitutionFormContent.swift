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

            if viewModel.isEditing {
                Button {
                    if viewModel.isArchived {
                        Task { await viewModel.unarchive() }
                    } else {
                        viewModel.showArchiveAlert = true
                    }
                } label: {
                    CustomButtonLabel(
                        iconLeading: viewModel.isArchived ? "tray.and.arrow.up" : "archivebox",
                        message: viewModel.isArchived ? "Désarchiver l'établissement" : "Archiver l'établissement",
                        color: viewModel.isArchived ? .blue : .orange,
                        isSelected: false
                    )
                }
                .disabled(viewModel.isLoading)
                .alert("Archiver l'établissement ?", isPresented: $viewModel.showArchiveAlert) {
                    Button("Archiver", role: .destructive) {
                        Task { await viewModel.archive() }
                    }
                    Button("Annuler", role: .cancel) {}
                } message: {
                    Text("Tous les comptes de cet établissement seront également archivés.")
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
