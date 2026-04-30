//
//  EchoLedgerApp.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/02/2026.
//

import SwiftUI
import FirebaseCore
import Toasty

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {

    /// Configures Firebase at app launch.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
    -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - EchoLedgerApp
@main
struct EchoLedgerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var toasty = ToastyManager()

    private let authStoring = AuthStoring(
        local: AuthLocalSource(),
        remote: AuthRemoteSource(),
        userRemote: UserRemoteSource()
    )

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                AppEntryView(authStoring: authStoring)
                    .environmentObject(toasty)
            }
        }
    }
}
