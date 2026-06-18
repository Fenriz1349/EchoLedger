//
//  AppEntryView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import Toasty

/// Thin root view: renders the current app phase and delegates all launch logic to
/// `AppEntryViewModel`. The view model is created and owned by `EchoLedgerApp`, so this
/// view only reads its phase and forwards user actions.
struct AppEntryView: View {

    @EnvironmentObject private var toasty: ToastyManager
    let viewModel: AppEntryViewModel
    let authStoring: AuthStoring

    var body: some View {
        ZStack {
            switch viewModel.phase {
            case .loading:
                LoadingView()
                    .transition(.opacity)
            case .auth:
                AuthView(
                    authStoring: authStoring,
                    toasty: toasty,
                    onAuthSuccess: { session in
                        Task { await viewModel.handleAuthSuccess(session: session) }
                    }
                )
                .transition(.opacity)
            case .app:
                if let coordinator = viewModel.coordinator, let container = viewModel.container {
                    ContentView(coordinator: coordinator)
                        .environment(container)
                        .id(container.userId)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.phase)
        .task {
            await viewModel.start()
        }
    }
}
