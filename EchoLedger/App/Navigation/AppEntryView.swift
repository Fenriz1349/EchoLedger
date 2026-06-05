//
//  AppEntryView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import Toasty

/// Manages app-phase transitions between loading, authentication, and main content.
struct AppEntryView: View {

    @EnvironmentObject private var toasty: ToastyManager
    @State private var phase: AppPhase = .loading
    @State private var container: DIContainer?
    @State private var coordinator: AppCoordinator?

    let authStoring: AuthStoring

    var body: some View {
        ZStack {
            switch phase {
            case .loading:
                LoadingView()
                    .transition(.opacity)
            case .auth:
                AuthView(authStoring: authStoring, toasty: toasty, onAuthSuccess: handleAuthSuccess)
                    .transition(.opacity)
            case .app:
                if let coordinator, let container {
                    ContentView(coordinator: coordinator)
                        .environment(container)
                        .id(container.userId)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: phase)
        .task { await resolveExistingSession() }
    }

    /// Attempts to restore an existing session at launch.
    /// Runs in parallel with a minimum display delay so the loading screen is never a flash.
    /// If an anonymous session has exceeded 7 days, deletes it and shows an expiration message.
    private func resolveExistingSession() async {
        async let minimumDelay: Void = Task.sleep(nanoseconds: 1_500_000_000)

        let resolve = ResolveSession(repository: authStoring)
        guard let session = await resolve.execute() else {
            try? await minimumDelay
            withAnimation(.easeInOut(duration: 0.4)) { phase = .auth }
            return
        }

        if session.isAnonymous {
            let expire = ExpireAnonymousSession(repository: authStoring)
            if await expire.execute() {
                try? await minimumDelay
                toasty.showInfo(AuthError.sessionExpired.errorDescription ?? "")
                withAnimation(.easeInOut(duration: 0.4)) { phase = .auth }
                return
            }
        }

        await buildApp(session: session)
        try? await minimumDelay
        withAnimation(.easeInOut(duration: 0.4)) { phase = .app }
    }

    /// Assembles the full dependency graph for the given session.
    /// Loads the current user profile and warms the local cache.
    /// - Parameter session: The authenticated session to build from.
    private func buildApp(session: AuthSession) async {
        let newContainer = DIContainer(
            userId: session.userId,
            toasty: toasty,
            authStoring: authStoring,
            authSession: session
        )

        do {
            let user = try await newContainer.getCurrentUser.execute()

            container = newContainer
            coordinator = AppCoordinator(
                container: newContainer,
                user: user,
                onSignOut: resetToAuth,
                onSessionUpdated: { [weak newContainer] session in
                    newContainer?.authSession = session
                }
            )

            #if !CLOUD_TARGET
            await newContainer.syncManager.sync()
            #endif
        } catch {
            toasty.showError(error)
            resetToAuth()
        }
    }

    /// Called on successful authentication from AuthView.
    /// - Parameter session: The authenticated session to build from.
    private func handleAuthSuccess(session: AuthSession) {
        Task {
            await buildApp(session: session)
            withAnimation(.easeInOut(duration: 0.4)) { phase = .app }
        }
    }

    /// Tears down the app state and returns to the authentication screen.
    private func resetToAuth() {
        container = nil
        coordinator = nil
        withAnimation(.easeInOut(duration: 0.4)) { phase = .auth }
    }
}

private enum AppPhase: Equatable {
    case loading, auth, app
}
