//
//  AuthView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import SwiftUI
import CustomLabels
import CustomTextFields
import Toasty

/// The authentication screen handling both sign-in and account creation.
struct AuthView: View {

    @State private var authViewModel: AuthViewModel

    /// - Parameters:
    ///   - authStoring: The authentication provider used to build use cases.
    ///   - toasty: The shared toast notification manager.
    ///   - onAuthSuccess: Closure called with the session once authentication succeeds.
    init(authStoring: AuthProviding, toasty: ToastyManager, onAuthSuccess: @escaping (AuthSession) -> Void) {
        _authViewModel = State(initialValue: AuthViewModel(
            toasty: toasty,
            signInWithEmail: SignInWithEmail(repository: authStoring),
            createUserProfile: CreateUserProfile(repository: authStoring),
            signInAnonymously: SignInAnonymously(repository: authStoring),
            onAuthSuccess: onAuthSuccess,
            resetPassword: ResetPassword(repository: authStoring)
        ))
    }

    var body: some View {
        @Bindable var viewModel = authViewModel

        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 24) {

               AppHeaderView()
                .padding(.top, 40)

                // MARK: Toggle
                Picker("", selection: $viewModel.isSignUp) {
                    Text("Connexion").tag(false)
                    Text("Inscription").tag(true)
                }
                .pickerStyle(.segmented)

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
        }
        .overlay {
            if viewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    AuthView(
        authStoring: PreviewData.authStoring,
        toasty: PreviewData.toasty,
        onAuthSuccess: { _ in }
    )
}
