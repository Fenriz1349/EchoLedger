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
            createAccount: CreateAccount(repository: authStoring),
            signInAnonymously: SignInAnonymously(repository: authStoring),
            onAuthSuccess: onAuthSuccess,
            resetPassword: ResetPassword(repository: authStoring)
        ))
    }

    var body: some View {
        @Bindable var viewModel = authViewModel

        ScrollView {
            VStack(spacing: 24) {

                // MARK: Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    Text("EchoLedger")
                        .font(.largeTitle.bold())
                }
                .padding(.top, 40)

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
                    confirmPasswordState: $viewModel.confirmPasswordState
                )

                // MARK: Password Reset
                if !viewModel.isSignUp {
                    Button {
                        Task { await viewModel.forgotPassword() }
                    } label: {
                        Text("Mot de passe oublié ?")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
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

                // MARK: Toggle
                Button {
                    viewModel.isSignUp.toggle()
                } label: {
                    CustomButtonLabel(
                        message: viewModel.isSignUp
                        ? "Déjà un compte ? Se connecter"
                        : "Pas encore de compte ? Créer un compte",
                        color: .accentColor,
                        isSelected: false
                    )
                }
                .disabled(viewModel.isLoading)

                // MARK: Demo Mode
                Button {
                    Task { await viewModel.continueAnonymously() }
                } label: {
                    Text("Continuer en mode démo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    EchoLedgerLoader().frame(width: 80, height: 80)
                }
            }
        }
    }
}
