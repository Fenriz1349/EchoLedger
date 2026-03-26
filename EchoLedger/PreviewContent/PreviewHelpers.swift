//
//  PreviewHelpers.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

extension DIContainer {

    /// Creates an in-memory container pre-populated with demo data.
    static func preview() -> DIContainer {
        DIContainer(inMemory: true)
    }
}

extension AddInstitutionFormViewModel {

    /// Creates a preview instance with demo data.
    static func preview(onAdd: @escaping (Institution) -> Void = { _ in }) -> AddInstitutionFormViewModel {
        let container = DIContainer.preview()
        return AddInstitutionFormViewModel(
            addInstitution: container.addInstitution,
            getInstitutions: container.getInstitutions,
            userId: PreviewData.user.id,
            onAdd: onAdd
        )
    }
}
