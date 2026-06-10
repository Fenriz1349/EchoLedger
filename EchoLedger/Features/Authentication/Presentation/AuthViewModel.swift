//
//  AuthViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation
import CustomTextFields
import Toasty

/// Manages state and logic for the authentication screen.
@Observable
@MainActor
final class AuthViewModel {

    // MARK: Form Fields
    var firstName = ""
    var lastName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    // MARK: Validation States
    var firstNameState: ValidationState = .neutral
    var lastNameState: ValidationState = .neutral
    var emailState: ValidationState = .neutral
    var passwordState: ValidationState = .neutral
    var confirmPasswordState: ValidationState = .neutral

    // MARK: UI State
    var isSignUp = false
    var isLoading = false

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let signInWithEmailUseCase: SignInWithEmail
    private let createUserProfileUseCase: CreateUserProfile
    private let signInAnonymouslyUseCase: SignInAnonymously
    private let resetPasswordUseCase: ResetPassword
    let onAuthSuccess: (AuthSession) -> Void

    /// A name is valid when it is not empty (ignoring whitespace).
    /// Shared by the text fields (display) and the form validity checks so both stay in sync.
    func isValidName(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// The confirmation is valid when it is not empty and matches the password.
    /// Lets the confirm field show the mismatch live, instead of only via the disabled button.
    func isValidConfirmPassword(_ value: String) -> Bool {
        !value.isEmpty && value == password
    }

    /// Returns true when all required fields are filled and valid.
    var isFormValid: Bool {
        let base = Validators.isValidEmail(email) && Validators.isStrongPassword(password)
        guard isSignUp else { return base }
        return base
            && isValidName(firstName)
            && isValidName(lastName)
            && password == confirmPassword
    }

    /// - Parameters:
    ///   - toasty: The shared toast notification manager.
    ///   - signInWithEmail: Use case for email/password sign-in.
    ///   - createUserProfile: Use case for new profile creation.
    ///   - signInAnonymously: Use case for anonymous demo session.
    ///   - onAuthSuccess: Closure called with the session once authentication succeeds.
    init(
        toasty: ToastyManager,
        signInWithEmail: SignInWithEmail,
        createUserProfile: CreateUserProfile,
        signInAnonymously: SignInAnonymously,
        onAuthSuccess: @escaping (AuthSession) -> Void,
        resetPassword: ResetPassword,
    ) {
        self.toasty = toasty
        self.signInWithEmailUseCase = signInWithEmail
        self.createUserProfileUseCase = createUserProfile
        self.signInAnonymouslyUseCase = signInAnonymously
        self.onAuthSuccess = onAuthSuccess
        self.resetPasswordUseCase = resetPassword
    }

    /// Validates and submits the form, signing in or creating an account depending on the current mode.
    func submit() async {
        guard validateForm() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let session: AuthSession
            if isSignUp {
                session = try await createUserProfileUseCase.execute(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
            } else {
                session = try await signInWithEmailUseCase.execute(email: email, password: password)
            }
            onAuthSuccess(session)
        } catch {
            toasty.showError(error)
        }
    }

    /// Starts an anonymous demo session.
    func continueAnonymously() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await signInAnonymouslyUseCase.execute()
            onAuthSuccess(session)
        } catch {
            toasty.showError(error)
        }
    }

    /// Sends a password reset email using the current email field value.
    func forgotPassword() async {
        guard Validators.isValidEmail(email) else {
            emailState = .invalid
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await resetPasswordUseCase.execute(email: email)
            toasty.showSuccess("Un email de réinitialisation a été envoyé.")
        } catch {
            toasty.showError(error)
        }
    }

    // MARK: Private

    /// Forces validation on all required fields and returns whether the form is valid.
    private func validateForm() -> Bool {
        var isValid = true

        if !Validators.isValidEmail(email) {
            emailState = .invalid
            isValid = false
        }
        if !Validators.isStrongPassword(password) {
            passwordState = .invalid
            isValid = false
        }
        if isSignUp {
            if !isValidName(firstName) {
                firstNameState = .invalid
                isValid = false
            }
            if !isValidName(lastName) {
                lastNameState = .invalid
                isValid = false
            }
            if password != confirmPassword {
                confirmPasswordState = .invalid
                isValid = false
            }
        }
        return isValid
    }
}
