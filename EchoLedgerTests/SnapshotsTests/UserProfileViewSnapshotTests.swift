//
//  UserProfileViewSnapshotTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import SwiftUI
@testable import EchoLedger

@MainActor
final class UserProfileViewSnapshotTests: XCTestCase {

    /// Verifies the appearance of the user profile screen, seeded with PreviewData's user.
    func test_userProfileView_appearance() throws {
        let viewModel = PreviewHelpers.makeUserProfileViewModel()
        viewModel.user = PreviewData.user

        let sut = UserProfileView(viewModel: viewModel)
            .environment(PreviewHelpers.container)
            .asViewController()

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "USER_PROFILE_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "USER_PROFILE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraSmall)),
              named: "USER_PROFILE_light_XS")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark, contentSize: .accessibilityExtraExtraExtraLarge)),
              named: "USER_PROFILE_dark_XXXL")
    }
}
