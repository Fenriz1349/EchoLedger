//
//  InstitutionType.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

import Foundation

enum InstitutionType: String, Codable, CaseIterable {
    case bank
    case crypto
    case cash
    case broker
    case unknown
}
