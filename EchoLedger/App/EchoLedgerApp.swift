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

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                Group {
                    if let coordinator, let container {
                        ContentView(coordinator: coordinator)
                            .environment(container)
                    } else {
                        ProgressView()
                    }
                }
                .task {
                    let authStoring = AuthStoring(local: AuthLocalSource(), remote: AuthRemoteSource())
                    let resolveSession = ResolveSession(repository: authStoring)

                    guard let session = try? await resolveSession.execute() else {
                        return
                    }

                    let newContainer = DIContainer(userId: session.userId)
                    container = newContainer
                    coordinator = AppCoordinator(container: newContainer)
                }
                .environmentObject(toasty)
            }
        }
    }
}
