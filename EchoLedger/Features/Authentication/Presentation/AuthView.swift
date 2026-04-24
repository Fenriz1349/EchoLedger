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
            onAuthSuccess: onAuthSuccess
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

                // MARK: Fields
                VStack(spacing: 16) {
                    if viewModel.isSignUp {
                        CustomTextField(placeholder: "Prénom", text: $viewModel.firstName, type: .lettersOnly,
                            errorMessage: "Le prénom est requis.",
                            validationState: $viewModel.firstNameState, showErrorOnlyWhenTriggered: false)
                        CustomTextField(placeholder: "Nom", text: $viewModel.lastName, type: .lettersOnly,
                            errorMessage: "Le nom est requis.",
                            validationState: $viewModel.lastNameState, showErrorOnlyWhenTriggered: false)
                    }
                    CustomTextField(placeholder: "Email", text: $viewModel.email, type: .email,
                        errorMessage: "Adresse email invalide.",
                        validationState: $viewModel.emailState, showErrorOnlyWhenTriggered: false)
                    CustomTextField(placeholder: "Mot de passe", text: $viewModel.password, type: .password,
                        errorMessage: AuthError.weakPassword.errorDescription,
                        validationState: $viewModel.passwordState, showErrorOnlyWhenTriggered: false)
                    if viewModel.isSignUp {
                        CustomTextField(placeholder: "Confirmer le mot de passe", text: $viewModel.confirmPassword, type: .password,
                            errorMessage: AuthError.passwordsDoNotMatch.errorDescription,
                            validationState: $viewModel.confirmPasswordState, showErrorOnlyWhenTriggered: false)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSignUp)

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
                        message: viewModel.isSignUp ? "Déjà un compte ? Se connecter" : "Pas encore de compte ? Créer un compte",
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
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
    }
}
