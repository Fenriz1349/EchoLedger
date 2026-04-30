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

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            Text("\(user.firstName) \(user.lastName)")
                .font(.title2.bold())

            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    UserProfileHeaderView(user: PreviewData.user)
}
