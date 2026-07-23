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

/// UIKit app delegate used only to configure Firebase before SwiftUI takes over the launch sequence.
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

/// Application entry point; owns the app-wide singletons and wires them into the root view.
@main
struct EchoLedgerApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var toasty: ToastyManager
    @State private var networkMonitor: NetworkMonitor
    @State private var viewModel: AppEntryViewModel

    /// Builds the shared toast manager, connectivity monitor, authentication provider and the
    /// app-level view model once, so the launch lifecycle owner is created before the first frame
    /// rather than lazily inside the root view.
    init() {
        let toasty = ToastyManager()
        let networkMonitor = NetworkMonitor()
        let authStoring = AuthStoring(
            local: AuthLocalSource(),
            remote: AuthRemoteSource(),
            userRemote: UserRemoteSource()
        )
        _toasty = StateObject(wrappedValue: toasty)
        _networkMonitor = State(initialValue: networkMonitor)
        _viewModel = State(initialValue: AppEntryViewModel(
            authStoring: authStoring,
            toasty: toasty,
            networkMonitor: networkMonitor
        ))
    }

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                AppEntryView(viewModel: viewModel)
                    .environmentObject(toasty)
                    .environment(networkMonitor)
            }
        }
    }
}
