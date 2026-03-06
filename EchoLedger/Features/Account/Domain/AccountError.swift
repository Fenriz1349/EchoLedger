//
//  AccountError.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

enum AccountError: Error, LocalizedError {
    case emptyName
    case unknown

    var errorDescription: String? {
        switch self {
        case .emptyName: return String(localized: "error.account.emptyName")
        case .unknown: return String(localized: "error.unknown")
        }
    }
}
