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

    // MARK: Network
    static let networkMonitor = NetworkMonitor()

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

    // MARK: Transfers
    static let transferExpense = Transaction(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000040")!,
        userId: user.id,
        label: "Virement Livret A",
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        totalAmount: 300,
        isExpense: true,
        category: .transfer,
        splits: [
            TransactionSplit(accountId: accountCourant.id, amount: 300)
        ]
    )

    static let transferIncome = Transaction(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000041")!,
        userId: user.id,
        label: "Virement Livret A",
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        totalAmount: 300,
        isExpense: false,
        category: .transfer,
        splits: [
            TransactionSplit(accountId: accountLivret.id, amount: 300)
        ]
    )

    static let transactions: [Transaction] = [
        transactionSalaire,
        transactionRestaurant,
        transactionCourses,
        transactionVirement,
        transferExpense,
        transferIncome
    ]

    // MARK: Chart sample (multi-month)

    /// ~6 months of varied transactions so chart previews (monthly bars,
    /// running balance, category pies) render with realistic data.
    /// Generated rather than hand-written to keep this file readable.
    static let chartTransactions: [Transaction] = {
        var result: [Transaction] = []
        let calendar = Calendar.current
        let now = Date()

        func date(monthsAgo: Int, day: Int) -> Date {
            let base = calendar.date(byAdding: .month, value: -monthsAgo, to: now) ?? now
            var comps = calendar.dateComponents([.year, .month], from: base)
            comps.day = day
            return calendar.date(from: comps) ?? base
        }

        func make(_ label: String, _ amount: Double, _ category: TransactionCategory,
                  _ isExpense: Bool, _ account: Account, _ day: Int, _ monthsAgo: Int) {
            result.append(Transaction(
                id: UUID(),
                userId: user.id,
                label: label,
                date: date(monthsAgo: monthsAgo, day: day),
                totalAmount: amount,
                isExpense: isExpense,
                category: category,
                splits: [TransactionSplit(accountId: account.id, amount: amount)]
            ))
        }

        for month in 0..<6 {
            let drift = Double(month) * 7 // makes monthly bars differ
            make("Salaire", 2300, .salary, false, accountCourant, 25, month)
            make("Loyer", 800, .rent, true, accountCourant, 3, month)
            make("Courses", 72 + drift, .grocery, true, accountCourant, 7, month)
            make("Courses", 48, .grocery, true, accountCourant, 19, month)
            make("Restaurant", 27, .restaurant, true, accountSwile, 12, month)
            make("Transport", 38, .transport, true, accountCourant, 9, month)
            make("Loisirs", 45 + drift, .leisure, true, accountCourant, 16, month)
            make("Abonnements", 26, .subscription, true, accountCourant, 5, month)
            if month % 3 == 0 {
                make("Intérêts Livret", 12, .investment, false, accountLivret, 28, month)
            }
        }
        return result
    }()
}
