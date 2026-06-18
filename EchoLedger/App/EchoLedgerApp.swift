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
    @StateObject private var toasty: ToastyManager
    @State private var viewModel: AppEntryViewModel
    private let authStoring: AuthStoring

    /// Builds the shared toast manager, the authentication provider and the app-level
    /// view model once, so the launch lifecycle owner is created before the first frame
    /// rather than lazily inside the root view.
    init() {
        let toasty = ToastyManager()
        let authStoring = AuthStoring(
            local: AuthLocalSource(),
            remote: AuthRemoteSource(),
            userRemote: UserRemoteSource()
        )
        _toasty = StateObject(wrappedValue: toasty)
        _viewModel = State(initialValue: AppEntryViewModel(authStoring: authStoring, toasty: toasty))
        self.authStoring = authStoring
    }

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                AppEntryView(viewModel: viewModel, authStoring: authStoring)
                    .environmentObject(toasty)
            }
        }
    }
}
