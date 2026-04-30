//
//  UserProfileAnonymousSectionView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import CustomLabels
import CustomTextFields

/// Displayed when the current session is anonymous.
/// Shows a demo mode banner and a form to create a permanent account.
struct UserProfileAnonymousSectionView: View {

    @Bindable var viewModel: UserProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Mode démo")
                    .font(.headline)
                Text("Vos données ne sont pas sauvegardées sur un compte permanent.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)

            Text("Créer un compte permanent")
                .font(.headline)

            AuthFormContent(
                isSignUp: .constant(true),
                firstName: $viewModel.linkFirstName,
                lastName: $viewModel.linkLastName,
                email: $viewModel.linkEmail,
                password: $viewModel.linkPassword,
                confirmPassword: $viewModel.linkConfirmPassword,
                firstNameState: $viewModel.linkFirstNameState,
                lastNameState: $viewModel.linkLastNameState,
                emailState: $viewModel.linkEmailState,
                passwordState: $viewModel.linkPasswordState,
                confirmPasswordState: $viewModel.linkConfirmPasswordState
            )

            Button {
                Task { await viewModel.linkAccount() }
            } label: {
                CustomButtonLabel(
                    message: "Créer mon compte",
                    color: .accentColor,
                    isSelected: viewModel.isLinkFormValid
                )
            }
            .disabled(!viewModel.isLinkFormValid || viewModel.isLoading)
        }
    }
}

#Preview {
    UserProfileAnonymousSectionView(viewModel: PreviewHelpers.makeUserProfileViewModel(isAnonymous: true))
        .padding()
}
