//
//  OfflineError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/06/2026.
//

import Foundation

/// Errors raised when a network operation can't proceed because the device or the
/// backend is unreachable. Used to cancel a write before it reaches Firestore (which
/// would otherwise queue it offline and sync it later, defeating the cancellation).
enum OfflineError: LocalizedError {
    /// The device has no active network interface.
    case notConnected
    /// The device is connected but the backend could not be reached (captive portal,
    /// VPN, server down…).
    case serverUnreachable

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Aucune connexion internet. Réessayez une fois connecté."
        case .serverUnreachable:
            return "Le serveur est injoignable. Réessayez dans un instant."
        }
    }
}
