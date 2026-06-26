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
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    AnonymousHeaderView(dayInDemo: viewModel.daysRemainingInDemo)

                    Button {
                        viewModel.showDeleteAlert = true
                    } label: {
                        CustomButtonLabel(message: "Arrêter l'essai", color: .orange, isSelected: false)
                    }
                    .disabled(viewModel.isLoading)

                    Divider()

                    Text("Créer un compte permanent")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

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
                        confirmPasswordState: $viewModel.linkConfirmPasswordState,
                        firstNameValidator: viewModel.isValidName,
                        lastNameValidator: viewModel.isValidName,
                        confirmPasswordValidator: viewModel.isValidConfirmPassword
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
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.immediately)
            .echoBackground()
            .alert("Arrêter l'essai ?", isPresented: $viewModel.showDeleteAlert) {
                Button("Arrêter", role: .destructive) {
                    Task { await viewModel.deleteUserProfile() }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Votre session de démo et ses données seront définitivement supprimées.")
            }
        }
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
