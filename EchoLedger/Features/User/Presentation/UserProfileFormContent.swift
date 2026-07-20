//
//  UserProfileFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

/// Displays user profile fields in read mode or edit mode.
struct UserProfileFormContent: View {

    @Bindable var viewModel: UserProfileViewModel

    var body: some View {
        VStack(spacing: 12) {
            CustomTextField(
                header: "Prénom",
                placeholder: "Prénom",
                text: $viewModel.firstName,
                type: .lettersOnly,
                validator: viewModel.isValidName,
                errorMessage: "Le prénom est requis.",
                validationState: $viewModel.firstNameEditState,
                colors: .echo,
                showErrorOnlyWhenTriggered: false,
                cornerRadius: .echoCorner,
                hasShadow: false
            )
            CustomTextField(
                header: "Nom",
                placeholder: "Nom",
                text: $viewModel.lastName,
                type: .lettersOnly,
                validator: viewModel.isValidName,
                errorMessage: "Le nom est requis.",
                validationState: $viewModel.lastNameEditState,
                colors: .echo,
                showErrorOnlyWhenTriggered: false,
                cornerRadius: .echoCorner,
                hasShadow: false
            )

            HStack {
                Button {
                    Task { await viewModel.updateProfile() }
                } label: {
                    CustomButtonLabel(message: "Enregistrer", color: .accentColor, isSelected: viewModel.isFormValid)
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)

                Button {
                    viewModel.cancelEdit()
                } label: {
                    CustomButtonLabel(message: "Annuler", color: .secondary, isSelected: false)
                }
            }
        }
    }
}

#Preview {
    let viewModel = PreviewHelpers.makeUserProfileViewModel()
    viewModel.startEditing()
    return UserProfileFormContent(viewModel: viewModel)
        .padding()
}
