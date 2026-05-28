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
    let avatarDocument: DocumentResult
    let onImageSelected: (Data) -> Void
    let onRemoveAvatar: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            UserAvatarView(
                document: avatarDocument,
                size: 140,
                onImageSelected: onImageSelected,
                onRemove: onRemoveAvatar
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
        avatarDocument: DocumentResult(urlString: nil, attachmentType: nil, placeholder: .avatar),
        onImageSelected: { _ in },
        onRemoveAvatar: {}
    )
}
