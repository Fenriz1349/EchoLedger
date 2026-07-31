//
//  LinkAccountFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 31/07/2026.
//

import SwiftUI
import CustomLabels

/// Converts the current demo session into a permanent account.
/// Presented as a sheet, not inline in the tab — a TabView tab doesn't reliably host the keyboard toolbar.
struct LinkAccountFormView: View {

    @Bindable var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Créer un compte permanent") {
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
                }
                .listRowBackground(Color.clear)

                Section {
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
                    .accessibilityIdentifier("button.linkAccountSubmit")
                }
                .listRowBackground(Color.clear)
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Créer un compte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Fermer") { UIView.dismissKeyboard() }
                    Spacer()
                    Button("Créer mon compte") {
                        UIView.dismissKeyboard()
                        Task { await viewModel.linkAccount() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isLinkFormValid || viewModel.isLoading)
                }
            }
            .onChange(of: viewModel.isAnonymous) {
                if !viewModel.isAnonymous { dismiss() }
            }
            .echoBackground()
        }
        .overlay {
            if viewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    LinkAccountFormView(viewModel: PreviewHelpers.makeUserProfileViewModel(isAnonymous: true))
}
