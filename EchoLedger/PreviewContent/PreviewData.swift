//
//  PreviewData.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation
import Toasty

/// Provides static sample data for SwiftUI previews.
/// Never used in production code.
enum PreviewData {

    // MARK: Toasty
    static let toasty = ToastyManager()

    // MARK: - Auth
    static let authSession = AuthSession(userId: user.id, isAnonymous: false)
    static let authStoring: AuthProviding = PreviewAuthStoring()

    // MARK: User
    static let user = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        displayName: "Bruce|Wayne",
        email: "batman@echoledger.app"
    )

    // MARK: Institutions
    static let institutionBNP = Institution(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
        userId: user.id,
        name: "BNP Paribas",
        category: .bank
    )

    static let institutionSwile = Institution(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
        userId: user.id,
        name: "Swile",
        category: .mealVoucher
    )

    static let institutionCaisse = Institution(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
        userId: user.id,
        name: "Caisse d'Épargne",
        category: .bank
    )

    static let institutions: [Institution] = [
        institutionBNP,
        institutionSwile,
        institutionCaisse
    ]

    // MARK: Accounts
    static let accountCourant = Account(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
        institutionId: institutionBNP.id,
        name: "Compte courant",
        category: .checking
    )

    static let accountLivret = Account(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
        institutionId: institutionCaisse.id,
        name: "Livret A",
        category: .savings
    )

    static let accountSwile = Account(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
        institutionId: institutionSwile.id,
        name: "Carte Swile",
        category: .mealVoucher
    )

    static let accounts: [Account] = [
        accountCourant,
        accountLivret,
        accountSwile
    ]

    static let institutionsWithAccounts: [(institution: Institution, accounts: [Account])] = [
        (institution: institutionBNP, accounts: [accountCourant]),
        (institution: institutionSwile, accounts: [accountSwile]),
        (institution: institutionCaisse, accounts: [accountLivret])
    ]

    // MARK: Transactions
    static let transactionRestaurant = Transaction(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
        userId: user.id,
        label: "Restaurant midi",
        date: Date(),
        totalAmount: 30,
        isExpense: true,
        category: .restaurant,
        splits: [
            TransactionSplit(accountId: accountCourant.id, amount: 15),
            TransactionSplit(accountId: accountSwile.id, amount: 15)
        ]
    )

    static let transactionSalaire = Transaction(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
        userId: user.id,
        label: "Salaire mars",
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        totalAmount: 2500,
        isExpense: false,
        category: .salary,
        splits: [
            TransactionSplit(accountId: accountCourant.id, amount: 2500)
        ]
    )

    static let transactionCourses = Transaction(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000032")!,
        userId: user.id,
        label: "Courses Monoprix",
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        totalAmount: 65,
        isExpense: true,
        category: .shopping,
        splits: [
            TransactionSplit(accountId: accountCourant.id, amount: 65)
        ]
    )

    static let transactionVirement = Transaction(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000033")!,
        userId: user.id,
        label: "Virement épargne",
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        totalAmount: 200,
        isExpense: true,
        category: .other,
        splits: [
            TransactionSplit(accountId: accountLivret.id, amount: 200)
        ]
    )

    static let transactions: [Transaction] = [
        transactionSalaire,
        transactionRestaurant,
        transactionCourses,
        transactionVirement
    ]
}
