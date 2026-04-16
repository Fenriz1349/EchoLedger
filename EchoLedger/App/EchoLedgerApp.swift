//
//  EchoLedgerApp.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/02/2026.
//

import SwiftUI
import FirebaseCore

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

    var body: some Scene {
        WindowGroup {
            Group {
                if let coordinator, let container {
                    ContentView(coordinator: coordinator)
                        .environment(container)
                } else {
                    ProgressView()
                }
            }
            .task {
                let userId = (try? await UserRemoteSource().signInAnonymously())?.toUUID ?? UUID()
                let newContainer = DIContainer(userId: userId)
                container = newContainer
                coordinator = AppCoordinator(container: newContainer)
            }
        }
    }
}
