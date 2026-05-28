//
//  GetUserPhoto.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Returns the document result for a user avatar.
/// Always uses the avatar placeholder — user photos are always images.
final class GetUserPhoto {

    func execute(user: User) -> DocumentResult {
        DocumentResult(
            urlString: user.photoURL,
            attachmentType: nil,
            placeholder: .avatar
        )
    }
}
