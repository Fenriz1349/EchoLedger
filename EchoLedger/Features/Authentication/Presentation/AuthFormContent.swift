//
//  AuthFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import SwiftUI
import CustomTextFields

/// Reusable form fields for authentication and account linking.
/// Purely presentational — contains no business logic.
struct AuthFormContent: View {

    @Binding var isSignUp: Bool
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var firstNameState: ValidationState
    @Binding var lastNameState: ValidationState
    @Binding var emailState: ValidationState
    @Binding var passwordState: ValidationState
    @Binding var confirmPasswordState: ValidationState

    var body: some View {
        VStack(spacing: 16) {
            if isSignUp {
                CustomTextField(
                    placeholder: "Prénom",
                    text: $firstName,
                    type: .lettersOnly,
                    errorMessage: "Le prénom est requis.",
                    validationState: $firstNameState,
                    showErrorOnlyWhenTriggered: false
                )
                CustomTextField(
                    placeholder: "Nom",
                    text: $lastName,
                    type: .lettersOnly,
                    errorMessage: "Le nom est requis.",
                    validationState: $lastNameState,
                    showErrorOnlyWhenTriggered: false
                )
            }
            CustomTextField(
                placeholder: "Email",
                text: $email,
                type: .email,
                errorMessage: "Adresse email invalide.",
                validationState: $emailState,
                showErrorOnlyWhenTriggered: false
            )
            CustomTextField(
                placeholder: "Mot de passe",
                text: $password,
                type: .password,
                errorMessage: AuthError.weakPassword.errorDescription,
                validationState: $passwordState,
                showErrorOnlyWhenTriggered: false
            )
            if isSignUp {
                CustomTextField(
                    placeholder: "Confirmer le mot de passe",
                    text: $confirmPassword,
                    type: .password,
                    errorMessage: AuthError.passwordsDoNotMatch.errorDescription,
                    validationState: $confirmPasswordState,
                    showErrorOnlyWhenTriggered: false
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSignUp)
    }
}
