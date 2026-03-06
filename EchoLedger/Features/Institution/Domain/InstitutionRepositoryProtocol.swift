//
//  InstitutionRepositoryProtocol.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

protocol InstitutionRepositoryProtocol {
    func createInstitution(name: String,
                           type: InstitutionType) throws -> Institution

    func fetchInstitutions() -> [Institution]

    func deleteInstitution(_ institution: Institution) throws
}
