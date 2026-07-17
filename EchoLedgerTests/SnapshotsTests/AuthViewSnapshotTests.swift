//
//  AuthViewSnapshotTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import SwiftUI
@testable import EchoLedger

@MainActor
final class AuthViewSnapshotTests: XCTestCase {

    /// Verifies the appearance of the sign-in screen in its default (sign-in, not sign-up) state.
    func test_authView_appearance() throws {
        let viewModel = AuthViewModel(
            toasty: PreviewData.toasty,
            signInWithEmail: SignInWithEmail(repository: PreviewData.authStoring),
            createUserProfile: CreateUserProfile(repository: PreviewData.authStoring),
            signInAnonymously: SignInAnonymously(repository: PreviewData.authStoring),
            onAuthSuccess: { _ in },
            resetPassword: ResetPassword(repository: PreviewData.authStoring)
        )

        let sut = AuthView(viewModel: viewModel).asViewController()

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "AUTH_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "AUTH_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraSmall)), named: "AUTH_light_XS")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark, contentSize: .accessibilityExtraExtraExtraLarge)),
              named: "AUTH_dark_XXXL")
    }
}
