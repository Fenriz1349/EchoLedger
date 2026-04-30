//
//  UserProfileView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import SwiftUI

/// Displays the user profile with options to view and edit info, sign out, or delete the account.
struct UserProfileView: View {

    @Bindable var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isAnonymous {
                        UserProfileAnonymousSectionView(viewModel: viewModel)
                    } else if let user = viewModel.user {
                        UserProfileHeaderView(user: user)
                        if viewModel.isEditing {
                            Divider()
                            UserProfileFormView(viewModel: viewModel)
                        }
                        Divider()
                        UserProfileAccountActionsView(viewModel: viewModel)
                    } else {
                        ProgressView()
                            .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .navigationTitle("Mon profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView().tint(.white).scaleEffect(1.5)
                    }
                }
            }
            .alert("Supprimer le compte", isPresented: $viewModel.showDeleteAlert) {
                Button("Supprimer", role: .destructive) {
                    Task { await viewModel.deleteAccount() }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action est irréversible. Toutes vos données seront supprimées.")
            }
        }
        .task { await viewModel.load() }
    }
}

#Preview("Logged in") {
    UserProfileView(viewModel: PreviewHelpers.makeUserProfileViewModel())
        .environment(PreviewHelpers.container)
}

#Preview("Anonymous") {
    UserProfileView(viewModel: PreviewHelpers.makeUserProfileViewModel(isAnonymous: true))
        .environment(PreviewHelpers.container)
}
