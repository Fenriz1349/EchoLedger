//
//  AppDelegate+UITesting.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/07/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

#if DEBUG
extension AppDelegate {

    /// Redirects Auth and Firestore to the local emulator suite and wipes any locally stored
    /// session, so UI tests never touch production data and always start from a deterministic
    /// blank slate. A UI test drives the app as an external process, so it cannot sign out or clear
    /// state through `@testable import` like the E2E tests do — without this, a session left over
    /// from a previous run (or from before the emulator was last restarted) makes
    /// `AppEntryViewModel` try to resolve it against Firestore, and the SDK doesn't time out cleanly
    /// on a session it can't validate, so the loading screen hangs.
    func configureForUITestingIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("--uitesting") else { return }

        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
        let settings = Firestore.firestore().settings
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings

        let authLocalSource = AuthLocalSource()
        authLocalSource.clearUserId()
        authLocalSource.clearAnonymousCreationDate()
        try? Auth.auth().signOut()
    }
}
#endif
