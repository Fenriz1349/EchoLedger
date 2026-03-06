//
//  AddInstitutionUseCase.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

struct AddInstitutionUseCase {
    let institutionRepository: InstitutionRepositoryProtocol
    let accountRepository: AccountRepositoryProtocol

    func execute(name: String,
                 type: InstitutionType,
                 initialBalance: Double) throws -> Institution {

        guard name.count >= 2 else {
            throw AccountError.emptyName
        }

        let institution = try institutionRepository.createInstitution(
            name: name,
            type: type
        )

        _ = try accountRepository.createAccount(
            name: name,
            type: .unknown,
            initialBalance: initialBalance,
            institution: institution
        )

        return institution
    }
}
