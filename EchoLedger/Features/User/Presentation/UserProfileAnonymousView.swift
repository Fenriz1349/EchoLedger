//
//  UserProfileAnonymousView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import CustomLabels
import CustomTextFields

/// Displayed when the current session is anonymous.
/// Shows a demo mode banner and a form to create a permanent account.
struct UserProfileAnonymousView: View {

    @Bindable var viewModel: UserProfileViewModel

    var body: some View {

        NavigationStack{
            VStack(spacing: 6) {
                Text("Mode démo")
                    .font(.headline)
                if let days = viewModel.daysRemainingInDemo {
                    Text("Il vous reste \(days) jour\(days > 1 ? "s" : "").")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                }
                Text("Vos données sont sauvegardées, mais accessibles uniquement depuis cet appareil. "
                     + "Créez un compte pour y accéder depuis n'importe où.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            
            Button {
                Task { await viewModel.signOut() }
            } label: {
                CustomButtonLabel(message: "Se déconnecter", color: .orange, isSelected: false)
            }
            .disabled(viewModel.isLoading)

            Form {
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
        .task { await viewModel.load() }
        .overlay {
            if viewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    UserProfileAnonymousView(viewModel: PreviewHelpers.makeUserProfileViewModel(isAnonymous: true))
        .padding()
}
