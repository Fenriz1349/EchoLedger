//
//  GetInstitutionsUseCase.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

struct GetInstitutionsUseCase {
    let repository: InstitutionRepositoryProtocol

    func execute() -> [Institution] {
        repository.fetchInstitutions()
    }
}
