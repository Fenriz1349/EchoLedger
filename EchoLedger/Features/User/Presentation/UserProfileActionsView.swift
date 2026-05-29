//
//  UserProfileActionsView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import CustomLabels

/// Displays account action buttons: edit profile, sign out, and delete account.
/// In edit mode, replaces the modifier button with save and cancel actions.
struct UserProfileActionsView: View {

    @Bindable var viewModel: UserProfileViewModel

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.isEditing {
                Button {
                    Task { await viewModel.updateProfile() }
                } label: {
                    CustomButtonLabel(message: "Enregistrer", color: .accentColor, isSelected: true)
                }
                .disabled(viewModel.isLoading)

                Button {
                    viewModel.cancelEdit()
                } label: {
                    CustomButtonLabel(message: "Annuler", color: .secondary, isSelected: false)
                }
            } else {
                Button {
                    viewModel.startEditing()
                } label: {
                    CustomButtonLabel(message: "Modifier", color: .accentColor, isSelected: false)
                }
                .disabled(viewModel.isLoading)

                Button {
                    Task { await viewModel.sendPasswordReset() }
                } label: {
                    Text("Réinitialiser le mot de passe par email")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
                .disabled(viewModel.isLoading)

                Button {
                    Task { await viewModel.signOut() }
                } label: {
                    CustomButtonLabel(message: "Se déconnecter", color: .orange, isSelected: false)
                }
                .disabled(viewModel.isLoading)

                Button {
                    viewModel.showDeleteAlert = true
                } label: {
                    CustomButtonLabel(message: "Supprimer mon compte", color: .red, isSelected: false)
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}

#Preview("Default") {
    UserProfileActionsView(viewModel: PreviewHelpers.makeUserProfileViewModel())
        .padding()
}

#Preview("Edit mode") {
    let viewModel = PreviewHelpers.makeUserProfileViewModel()
    viewModel.startEditing()
    return UserProfileActionsView(viewModel: viewModel)
        .padding()
}
