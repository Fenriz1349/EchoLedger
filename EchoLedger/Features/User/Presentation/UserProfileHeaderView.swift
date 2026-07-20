//
//  UserProfileHeaderView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI

/// Displays the user's avatar, full name, and email address.
struct UserProfileHeaderView: View {

    let user: User
    let avatarData: Data?
    let onImageSelected: (Data) -> Void
    let onRemoveAvatar: () -> Void
    let onEditBlocked: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            UserAvatarView(
                imageData: avatarData,
                size: 140,
                onImageSelected: onImageSelected,
                onRemove: onRemoveAvatar,
                onEditBlocked: onEditBlocked
            )

            Text("\(user.firstName) \(user.lastName)")
                .font(.title2.bold())

            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    UserProfileHeaderView(
        user: PreviewData.user,
        avatarData: nil,
        onImageSelected: { _ in },
        onRemoveAvatar: {},
        onEditBlocked: nil
    )
}
