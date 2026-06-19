//
//  AppEntryView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI

/// Thin root view: renders the current app phase and delegates all launch logic to
/// `AppEntryViewModel`. The view model is created and owned by `EchoLedgerApp`, so this
/// view only reads its phase and forwards user actions.
struct AppEntryView: View {

    let viewModel: AppEntryViewModel

    var body: some View {
        ZStack {
            switch viewModel.phase {
            case .loading:
                LoadingView()
                    .transition(.opacity)
            case .auth:
                AuthView(viewModel: viewModel.makeAuthViewModel())
                    .transition(.opacity)
            case .app:
                if let coordinator = viewModel.coordinator, let container = viewModel.container {
                    ContentView(coordinator: coordinator)
                        .environment(container)
                        .id(container.userId)
                        .transition(.opacity)
                }
            case .offline:
                OfflineView(onRetry: { Task { await viewModel.retry() } })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.phase)
        .task {
            await viewModel.start()
        }
    }
}
