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
    /// Name validity rule, provided by the owning ViewModel (keeps the rule out of the view).
    let firstNameValidator: (String) -> Bool
    let lastNameValidator: (String) -> Bool

    var body: some View {
        VStack(spacing: 16) {
            if isSignUp {
                CustomTextField(
                    placeholder: "Prénom",
                    text: $firstName,
                    type: .lettersOnly,
                    validator: firstNameValidator,
                    errorMessage: "Le prénom est requis.",
                    validationState: $firstNameState,
                    colors: .echo,
                    showErrorOnlyWhenTriggered: false
                )
                CustomTextField(
                    placeholder: "Nom",
                    text: $lastName,
                    type: .lettersOnly,
                    validator: lastNameValidator,
                    errorMessage: "Le nom est requis.",
                    validationState: $lastNameState,
                    colors: .echo,
                    showErrorOnlyWhenTriggered: false
                )
            }
            CustomTextField(
                placeholder: "Email",
                text: $email,
                type: .email,
                errorMessage: "Adresse email invalide.",
                validationState: $emailState,
                colors: .echo,
                showErrorOnlyWhenTriggered: false
            )
            CustomTextField(
                placeholder: "Mot de passe",
                text: $password,
                type: .password,
                errorMessage: AuthError.weakPassword.errorDescription,
                validationState: $passwordState,
                colors: .echo,
                showErrorOnlyWhenTriggered: false
            )
            if isSignUp {
                CustomTextField(
                    placeholder: "Confirmer le mot de passe",
                    text: $confirmPassword,
                    type: .password,
                    errorMessage: AuthError.passwordsDoNotMatch.errorDescription,
                    validationState: $confirmPasswordState,
                    colors: .echo,
                    showErrorOnlyWhenTriggered: false
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSignUp)
    }
}
