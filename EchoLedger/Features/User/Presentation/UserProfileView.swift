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
            VStack(spacing: 24) {
                if let user = viewModel.user {
                    UserProfileHeaderView(
                        user: user,
                        avatarDocument: viewModel.avatarDocument,
                        onImageSelected: { data in Task { await viewModel.uploadAvatar(data: data) } },
                        onRemoveAvatar: { Task { await viewModel.removeAvatar() } },
                        onEditBlocked: DocumentError.isSimulator ? { viewModel.showSimulatorWarning() } : nil,
                    )
                    if viewModel.isEditing {
                        UserProfileFormContent(viewModel: viewModel)
                            .padding(.horizontal, 24)
                    }
                    Divider()
                    UserProfileActionsView(viewModel: viewModel)
                        .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Mon profil")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.isEditing {
                            viewModel.cancelEdit()
                        } else {
                            viewModel.startEditing()
                        }
                    } label: {
                        Image(systemName: viewModel.isEditing ? "xmark" : "pencil")
                    }
                }
            }
            .alert("Supprimer le compte", isPresented: $viewModel.showDeleteAlert) {
                Button("Supprimer", role: .destructive) {
                    Task { await viewModel.deleteUserProfil() }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action est irréversible. Toutes vos données seront supprimées.")
            }
        }
        .task { await viewModel.load() }
        .overlay {
            if viewModel.isLoading || viewModel.isUploadingAvatar {
                EchoProgressView()
            }
        }
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
