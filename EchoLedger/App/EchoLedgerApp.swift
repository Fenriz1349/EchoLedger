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
    @State private var container: DIContainer?
    @State private var coordinator: AppCoordinator?
    @StateObject private var toasty = ToastyManager()

    private let authStoring = AuthStoring(
        local: AuthLocalSource(),
        remote: AuthRemoteSource(),
        userRemote: UserRemoteSource()
    )

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                Group {
                    if let coordinator, let container {
                        ContentView(coordinator: coordinator)
                            .environment(container)
                    } else {
                        AuthView(authStoring: authStoring, toasty: toasty, onAuthSuccess: buildApp)
                    }
                }
                .task { await resolveExistingSession() }
                .environmentObject(toasty)
            }
        }
    }

    /// Attempts to restore an existing session from local storage at launch.
    private func resolveExistingSession() async {
        let resolve = ResolveSession(repository: authStoring)
        if let session = await resolve.execute() {
            buildApp(session: session)
        }
    }

    /// Assembles the full dependency graph and activates the main app for the given session.
    /// - Parameter session: The authenticated session to build from.
    private func buildApp(session: AuthSession) {
        let newContainer = DIContainer(
            userId: session.userId,
            toasty: toasty,
            authStoring: authStoring,
            authSession: session
        )
        container = newContainer
        coordinator = AppCoordinator(container: newContainer, onSignOut: resetToAuth)
    }

    /// Tears down the app state and returns to the authentication screen.
    private func resetToAuth() {
        container = nil
        coordinator = nil
    }
}
