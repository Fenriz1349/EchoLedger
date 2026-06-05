//
//  PreviewHelpersCloud.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Provides pre-configured ViewModels and a DIContainer for SwiftUI previews in the Cloud target.
/// No SwiftData seeding — previews connect directly to Firebase and reflect live data.
struct PreviewHelpers {

    static let container = DIContainer(
        userId: PreviewData.user.id,
        toasty: PreviewData.toasty,
        authStoring: PreviewData.authStoring,
        authSession: PreviewData.authSession
    )

    /// Creates a preview AppCoordinator wired to the Cloud container.
    static var appCoordinator: AppCoordinator {
        AppCoordinator(
            container: container,
            user: PreviewData.user,
            onSignOut: {},
            onSessionUpdated: { _ in }
        )
    }

    /// - Returns: A UserProfileViewModel wired to the Cloud container.
    static func makeUserProfileViewModel(
        isAnonymous: Bool = false,
        onSignOut: @escaping () -> Void = {},
        onSessionUpdated: @escaping (AuthSession) -> Void = { _ in }
    ) -> UserProfileViewModel {
        container.makeUserProfileViewModel(
            user: PreviewData.user,
            onSignOut: onSignOut,
            onSessionUpdated: onSessionUpdated
        )
    }

    /// - Returns: An AccountFormViewModel wired to the Cloud container.
    static func makeAccountFormViewModel(existing: Account? = nil) -> AccountFormViewModel {
        container.makeAccountFormViewModel(existing: existing)
    }

    /// - Returns: An InstitutionFormViewModel in creation mode.
    static func makeAddInstitutionFormViewModel(onAdd: @escaping (Institution) -> Void = { _ in })
    -> InstitutionFormViewModel {
        container.makeInstitutionFormViewModel(onAdd: onAdd)
    }

    /// - Returns: An InstitutionFormViewModel wired to the Cloud container.
    static func makeInstitutionFormViewModel(existing: Institution? = nil) -> InstitutionFormViewModel {
        container.makeInstitutionFormViewModel(existing: existing)
    }

    /// - Returns: An AccountListViewModel wired to the Cloud container.
    static func makeAccountListViewModel() -> AccountListViewModel {
        container.makeAccountListViewModel()
    }

    /// - Returns: A TransactionFormViewModel wired to the Cloud container.
    static func makeTransactionFormViewModel() -> TransactionFormViewModel {
        container.makeTransactionFormViewModel()
    }

    /// - Returns: A TransferFormViewModel wired to the Cloud container.
    static var transferFormViewModel: TransferFormViewModel {
        container.makeTransferFormViewModel()
    }

    /// - Returns: A TransactionListViewModel wired to the Cloud container.
    static func makeTransactionListViewModel() -> TransactionListViewModel {
        container.makeTransactionListViewModel()
    }
}
