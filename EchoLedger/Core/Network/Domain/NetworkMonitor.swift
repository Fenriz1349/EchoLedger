//
//  NetworkMonitor.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/06/2026.
//

import Foundation
import Network

/// Tracks connectivity in two complementary ways:
/// - `isConnected`: the device's interface status, updated live by `NWPathMonitor`. Cheap, but
///   reflects the interface only — it can be `true` with no usable internet (captive portal, VPN).
/// - `verifyReachable()`: an actual round-trip to the backend, the source of truth before a write.
///
/// The split lets writes gate on real reachability (cancelling before Firestore queues the write
/// offline) while the UI banner relies on the cheap continuous signal.
@MainActor
@Observable
final class NetworkMonitor {

    /// Whether the device currently has an active network interface. Use it for the offline
    /// banner and as a free first gate — not as proof the backend is reachable.
    private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.echoledger.networkmonitor")

    /// Pinged to confirm reachability. Firestore itself, so a successful response proves both
    /// internet access and backend availability in one shot.
    private let reachabilityURL = URL(string: "https://firestore.googleapis.com")!

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            Task { @MainActor in self?.isConnected = connected }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    /// Two-stage reachability gate: the cheap interface check, then a real round-trip to the
    /// backend. Call before a write so it can be cancelled before reaching Firestore.
    /// - Throws: `OfflineError.notConnected` if the interface is down,
    ///   `OfflineError.serverUnreachable` if the backend can't be reached.
    func verifyReachable() async throws {
        guard isConnected else { throw OfflineError.notConnected }
        guard await ping() else { throw OfflineError.serverUnreachable }
    }

    /// Sends a short HEAD request to the backend. Any HTTP response means reachable; a thrown
    /// error (timeout, no route) means it isn't.
    private func ping() async -> Bool {
        var request = URLRequest(url: reachabilityURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return response is HTTPURLResponse
        } catch {
            return false
        }
    }
}
