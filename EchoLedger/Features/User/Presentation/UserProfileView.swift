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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isAnonymous {
                        UserProfileAnonymousSectionView(viewModel: viewModel)
                    } else if let user = viewModel.user {
                        UserProfileHeaderView(
                            user: user,
                            avatarDocument: viewModel.avatarDocument,
                            onImageSelected: { data in Task { await viewModel.uploadAvatar(data: data) } },
                            onRemoveAvatar: { Task { await viewModel.removeAvatar() } }
                        )
                        if viewModel.isEditing {
                            Divider()
                            UserProfileFormView(viewModel: viewModel)
                        }
                        Divider()
                        UserProfileActionsView(viewModel: viewModel)
                    } else {
                        EchoLedgerLoader()
                            .frame(width: 160, height: 160)
                            .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .navigationTitle("Mon profil")
            .overlay {
                if viewModel.isLoading || viewModel.isUploadingAvatar {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        EchoLedgerLoader()
                            .frame(width: 80, height: 80)
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
    let viewModel = PreviewHelpers.makeUserProfileViewModel()
    viewModel.user = PreviewData.user
    return UserProfileView(viewModel: viewModel)
        .environment(PreviewHelpers.container)
}

#Preview("Anonymous") {
    UserProfileView(viewModel: PreviewHelpers.makeUserProfileViewModel(isAnonymous: true))
        .environment(PreviewHelpers.container)
}
