//
//  AuthView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import SwiftUI
import CustomLabels
import CustomTextFields

/// The authentication screen handling both sign-in and account creation.
struct AuthView: View {

    @State private var viewModel: AuthViewModel

    /// Stores the injected view model in `@State` so the typed input survives re-renders.
    /// No construction here — the view model is built by `AppEntryViewModel.makeAuthViewModel()`.
    init(viewModel: AuthViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 24) {

            AppHeaderView()
                .padding(.top, 40)

            SegmentedToggle(selection: $viewModel.isSignUp, style: .authentication)

            AuthFormContent(
                isSignUp: $viewModel.isSignUp,
                firstName: $viewModel.firstName,
                lastName: $viewModel.lastName,
                email: $viewModel.email,
                password: $viewModel.password,
                confirmPassword: $viewModel.confirmPassword,
                firstNameState: $viewModel.firstNameState,
                lastNameState: $viewModel.lastNameState,
                emailState: $viewModel.emailState,
                passwordState: $viewModel.passwordState,
                confirmPasswordState: $viewModel.confirmPasswordState,
                firstNameValidator: viewModel.isValidName,
                lastNameValidator: viewModel.isValidName,
                confirmPasswordValidator: viewModel.isValidConfirmPassword
            )
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Fermer") { UIView.dismissKeyboard() }
                    Spacer()
                    Button(viewModel.isSignUp ? "Créer mon compte" : "Se connecter") {
                        UIView.dismissKeyboard()
                        Task { await viewModel.submit() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }

            // MARK: Password Reset
            if !viewModel.isSignUp {
                Button {
                    Task { await viewModel.forgotPassword() }
                } label: {
                    Text("Mot de passe oublié ?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .disabled(viewModel.isLoading)
            }

            // MARK: Submit
            Button {
                Task { await viewModel.submit() }
            } label: {
                CustomButtonLabel(
                    message: viewModel.isSignUp ? "Créer mon compte" : "Se connecter",
                    color: .accentColor,
                    isSelected: viewModel.isFormValid
                )
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)

            Divider()

            // MARK: Demo Mode
            Button {
                Task { await viewModel.continueAnonymously() }
            } label: {
                CustomButtonLabel(
                    message: "Continuer en mode démo",
                    color: .accentColor,
                    isSelected: false
                )
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .echoBackground()
        .overlay {
            if viewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel(
        toasty: PreviewData.toasty,
        signInWithEmail: SignInWithEmail(repository: PreviewData.authStoring),
        createUserProfile: CreateUserProfile(repository: PreviewData.authStoring),
        signInAnonymously: SignInAnonymously(repository: PreviewData.authStoring),
        onAuthSuccess: { _ in },
        resetPassword: ResetPassword(repository: PreviewData.authStoring)
    ))
}
