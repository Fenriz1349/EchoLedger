//
//  UserProfileAnonymousView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import CustomLabels

/// Displayed when the current session is anonymous.
/// Shows a demo mode banner and an entry point to create a permanent account.
struct UserProfileAnonymousView: View {

    @Bindable var viewModel: UserProfileViewModel
    @State private var showLinkAccountForm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    AnonymousHeaderView(dayInDemo: viewModel.daysRemainingInDemo)

                    Button {
                        showLinkAccountForm = true
                    } label: {
                        CustomButtonLabel(message: "Créer un compte permanent", color: .accentColor, isSelected: false)
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityIdentifier("button.showLinkAccountForm")

                    Button {
                        viewModel.showDeleteAlert = true
                    } label: {
                        CustomButtonLabel(message: "Arrêter l'essai", color: .orange, isSelected: false)
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityIdentifier("button.stopDemo")
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 40)
            }
            .echoBackground()
            .sheet(isPresented: $showLinkAccountForm) {
                LinkAccountFormView(viewModel: viewModel)
            }
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
