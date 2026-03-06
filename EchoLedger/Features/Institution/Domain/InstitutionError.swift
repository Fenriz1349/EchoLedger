//
//  InstitutionError.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

enum InstitutionError: Error, LocalizedError {
    case invalidName
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return String(localized: "error.institution.invalidName")
        case .unknown:
            return String(localized: "error.unknown")
        }
    }
}
