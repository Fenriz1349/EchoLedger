//
//  AppEntryViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/06/2026.
//

import Foundation
import Toasty

/// Owns the app's launch lifecycle: the phase machine (loading / auth / app),
/// session resolution, and assembly of the dependency graph once authenticated.
///
/// This is the single app-level presentation owner — distinct from `AppCoordinator`,
/// which only composes the feature view models for an authenticated session. The two
/// have different lifetimes: this view model lives for the whole app, the coordinator
/// is rebuilt on sign-in and torn down on sign-out. It is also the natural future home
/// for launch connectivity handling and pre-filling the view models before `.app`.
@MainActor
@Observable
final class AppEntryViewModel {

    /// The top-level screen the app is currently showing.
    enum Phase: Equatable {
        case loading, auth, app, offline
    }

    // MARK: State

    private(set) var phase: Phase = .loading
    private(set) var container: DIContainer?
    private(set) var coordinator: AppCoordinator?

    /// A resolved session that couldn't be built because the backend was unreachable. Kept so the
    /// offline screen can retry without forcing the user back through authentication.
    private var pendingSession: AuthSession?

    // MARK: Dependencies

    private let authStoring: AuthStoring
    private let toasty: ToastyManager
    private let networkMonitor: NetworkMonitor

    /// - Parameters:
    ///   - authStoring: The authentication provider used to resolve and tear down sessions.
    ///   - toasty: The shared toast manager for surfacing launch-time errors.
    ///   - networkMonitor: The shared connectivity monitor, forwarded to the dependency container.
    init(authStoring: AuthStoring, toasty: ToastyManager, networkMonitor: NetworkMonitor) {
        self.authStoring = authStoring
        self.toasty = toasty
        self.networkMonitor = networkMonitor
    }

    // MARK: Launch

    /// Entry point called once when the root view appears.
    func start() async {
        await resolveExistingSession()
    }

    /// Builds the app for a freshly authenticated session and enters the app phase.
    /// - Parameter session: The session returned by a successful sign-in.
    func handleAuthSuccess(session: AuthSession) async {
        if await buildApp(session: session) {
            phase = .app
        }
    }

    /// Retries after an offline launch — from the kept session if there was one, otherwise by
    /// resolving the session again. Triggered by the offline screen's button or automatically when
    /// connectivity returns.
    func retry() async {
        phase = .loading
        if let session = pendingSession {
            if await buildApp(session: session) {
                pendingSession = nil
                phase = .app
            }
        } else {
            await resolveExistingSession()
        }
    }

    // MARK: Private

    /// Attempts to restore an existing session at launch.
    /// Runs in parallel with a minimum display delay so the loading screen is never a flash.
    /// If an anonymous session has exceeded 7 days, deletes it and shows an expiration message.
    private func resolveExistingSession() async {
        async let minimumDelay: Void = Task.sleep(nanoseconds: 1_500_000_000)

        let resolve = ResolveSession(repository: authStoring)
        guard let session = await resolve.execute() else {
            // No stored session: offline → show the offline screen (authentication needs a network
            // anyway); online → go to authentication.
            let reachable = await currentlyReachable()
            try? await minimumDelay
            phase = reachable ? .auth : .offline
            return
        }

        if session.isAnonymous {
            let expire = ExpireAnonymousSession(repository: authStoring)
            if await expire.execute() {
                try? await minimumDelay
                toasty.showInfo(AuthError.sessionExpired.errorDescription ?? "")
                phase = .auth
                return
            }
        }

        let didBuild = await buildApp(session: session)
        try? await minimumDelay
        if didBuild {
            phase = .app
        }
    }

    /// Assembles the full dependency graph for the given session and loads the user profile.
    /// - Parameter session: The authenticated session to build from.
    /// - Returns: True if the app was built successfully, false if it fell back to auth.
    private func buildApp(session: AuthSession) async -> Bool {
        let newContainer = DIContainer(
            userId: session.userId,
            toasty: toasty,
            authStoring: authStoring,
            authSession: session,
            networkMonitor: networkMonitor
        )

        do {
            let user = try await newContainer.getCurrentUser.execute()

            container = newContainer
            coordinator = AppCoordinator(
                container: newContainer,
                user: user,
                onSignOut: { [weak self] in self?.resetToAuth() },
                onSessionUpdated: { [weak newContainer] session in
                    newContainer?.authSession = session
                }
            )

            #if !CLOUD_TARGET
            await newContainer.syncManager.sync()
            #endif

            // Pre-fill the main tabs while the loading screen is still up, so the app opens
            // already populated and the screens never show a per-screen loader afterwards.
            await coordinator?.loadData()
            return true
        } catch is OfflineError {
            // Backend unreachable → transient: keep the session and offer a retry, no sign-out.
            pendingSession = session
            phase = .offline
            return false
        } catch {
            // Reachable but the load still failed → genuine error (e.g. missing user) → back to auth.
            toasty.showError(error)
            try? await authStoring.signOut()
            resetToAuth()
            return false
        }
    }

    /// Actively checks whether the backend is reachable right now (a real round-trip, robust to the
    /// interface flag still being stale at launch).
    private func currentlyReachable() async -> Bool {
        do {
            try await networkMonitor.verifyReachable()
            return true
        } catch {
            return false
        }
    }

    /// Tears down the app state and returns to the authentication screen.
    private func resetToAuth() {
        container = nil
        coordinator = nil
        phase = .auth
    }
}
