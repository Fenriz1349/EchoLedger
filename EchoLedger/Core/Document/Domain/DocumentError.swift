//
//  DocumentError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 04/06/2026.
//

import Foundation

/// Errors specific to document upload and storage operations.
enum DocumentError: LocalizedError {
    case simulatorNotSupported

    /// True when running on the iOS Simulator where Firebase Storage TLS fails.
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    var errorDescription: String? {
        switch self {
        case .simulatorNotSupported:
            return "L'upload de fichiers n'est pas disponible sur le simulateur."
        }
    }
}
