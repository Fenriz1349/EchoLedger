//
//  DIContainerCloud.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseAuth
import Toasty

/// Firebase-only dependency container for EchoLedgerCloud target.
/// No SwiftData, no local sources, no SyncManager.
/// Firestore offline persistence is enabled by default by the Firebase SDK.
@MainActor
@Observable
final class DIContainer {

    // MARK: Remote Sources
    let userRemote = UserRemoteSource()
    let institutionRemote = InstitutionRemoteSource()
    let accountRemote = AccountRemoteSource()
    let transactionRemote = TransactionRemoteSource()

    // MARK: Auth
    let authStoring: AuthProviding
    var authSession: AuthSession

    // MARK: User
    let userId: UUID

    // MARK: Toasty
    let toasty: ToastyManager

    // MARK: Network
    let networkMonitor: NetworkMonitor

    // MARK: Storings
    let userStoring: UserProviding
    let institutionStoring: InstitutionProviding
    let accountStoring: AccountProviding
    let transactionStoring: TransactionProviding

    // MARK: Use Cases — Auth
    let signOut: SignOut
    let deleteUserRule: DeleteUserRule
    let linkAnonymousAccount: LinkAnonymousAccount
    let resetPassword: ResetPassword

    // MARK: Use Cases — User
    let getCurrentUser: GetCurrentUser
    let updateUser: UpdateUser

    // MARK: Use Cases — Institution
    let addInstitution: AddInstitution
    let getInstitutions: GetInstitutions
    let getInstitution: GetInstitution
    let updateInstitution: UpdateInstitution
    let archiveInstitutionRule: ArchiveInstitutionRule
    let unarchiveInstitutionRule: UnarchiveInstitutionRule
    let deleteInstitutionRule: DeleteInstitutionRule

    // MARK: Use Cases — Account
    let addAccount: AddAccount
    let getAccounts: GetAccounts
    let getAccount: GetAccount
    let updateAccount: UpdateAccount
    let archiveAccount: ArchiveAccount
    let unarchiveAccountRule: UnarchiveAccountRule
    let getAccountBalance: GetAccountBalance
    let getAccountsWithInstitution: GetAccountsWithInstitution
    let deleteAccountRule: DeleteAccountRule

    // MARK: Use Cases — Transfer
    let transferBetweenAccounts: TransferBetweenAccounts
    let deleteTransfer: DeleteTransfer
    let updateTransfer: UpdateTransfer

    // MARK: Use Cases — Transaction
    let addTransaction: AddTransaction
    let getTransactions: GetTransactions
    let getTransaction: GetTransaction
    let updateTransaction: UpdateTransaction
    let deleteTransaction: DeleteTransaction
    let getTransactionsByCategory: GetTransactionsByCategory
    let getTransactionsByDateRange: GetTransactionsByDateRange
    let getAccountsSortedByRecency: GetAccountsSortedByRecency

    // MARK: Use Cases — Document
    let uploadTransactionDocument: UploadTransactionDocument
    let uploadAvatarPhoto: UploadAvatarPhoto
    let deleteDocument: DeleteDocument
    let getTransactionDocument: GetTransactionDocument
    let downloadImage: DownloadImage

    // MARK: Use Cases — Charts
    let getChartData: GetChartData

    // MARK: Use Cases — Reload
    let refreshFromRemote: RefreshFromRemote

    // MARK: Init

    /// Creates the container with all resolved dependencies, wiring every storing directly to Firestore.
    /// - Parameters:
    ///   - userId: The stable UUID derived from the authentication session.
    ///   - toasty: The shared toast notification manager.
    ///   - authStoring: The authentication provider used for sign-out and account deletion.
    ///   - authSession: The current authentication session.
    ///   - networkMonitor: The shared connectivity monitor used to gate remote writes.
    init(userId: UUID, toasty: ToastyManager, authStoring: AuthProviding,
         authSession: AuthSession, networkMonitor: NetworkMonitor) {
        self.userId = userId
        self.toasty = toasty
        self.authStoring = authStoring
        self.authSession = authSession
        self.networkMonitor = networkMonitor

        let firebaseUID = Auth.auth().currentUser?.uid ?? ""

        // MARK: Cloud Storings
        let userCloud = UserCloudStoring(remote: userRemote, userId: userId, firebaseUID: firebaseUID,
                                         networkMonitor: networkMonitor)
        let institutionCloud = InstitutionCloudStoring(remote: institutionRemote, userId: userId,
                                                       networkMonitor: networkMonitor)
        let accountCloud = AccountCloudStoring(remote: accountRemote, userId: userId,
                                               networkMonitor: networkMonitor)
        let transactionCloud = TransactionCloudStoring(remote: transactionRemote, userId: userId,
                                                       networkMonitor: networkMonitor)

        self.userStoring = userCloud
        self.institutionStoring = institutionCloud
        self.accountStoring = accountCloud
        self.transactionStoring = transactionCloud

        // MARK: Document source (needed by the delete use cases below)
        let documentSource = DocumentRemoteSource(networkMonitor: networkMonitor)
        self.deleteDocument = DeleteDocument(documentSource: documentSource)

        // MARK: Use Cases — Auth
        self.signOut = SignOut(repository: authStoring)
        self.linkAnonymousAccount = LinkAnonymousAccount(repository: authStoring)
        self.resetPassword = ResetPassword(repository: authStoring)

        // MARK: Use Cases — User
        self.getCurrentUser = GetCurrentUser(repository: userCloud)
        self.updateUser = UpdateUser(repository: userCloud)

        // MARK: Use Cases — Institution
        self.addInstitution = AddInstitution(repository: institutionCloud)
        self.getInstitutions = GetInstitutions(repository: institutionCloud)
        self.getInstitution = GetInstitution(repository: institutionCloud)
        self.updateInstitution = UpdateInstitution(repository: institutionCloud)
        let archiveInstitution = ArchiveInstitution(repository: institutionCloud)
        let unarchiveInstitution = UnarchiveInstitution(repository: institutionCloud)

        // MARK: Use Cases — Account
        self.addAccount = AddAccount(repository: accountCloud)
        self.getAccounts = GetAccounts(repository: accountCloud)
        self.getAccount = GetAccount(repository: accountCloud)
        self.updateAccount = UpdateAccount(repository: accountCloud)
        self.archiveAccount = ArchiveAccount(repository: accountCloud)
        let unarchiveAccount = UnarchiveAccount(repository: accountCloud)
        self.getAccountBalance = GetAccountBalance(
            accountRepository: accountCloud,
            transactionRepository: transactionCloud
        )
        self.getAccountsWithInstitution = GetAccountsWithInstitution(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts
        )

        // MARK: Cascade Rules — archive/unarchive
        self.archiveInstitutionRule = ArchiveInstitutionRule(
            getAccounts: getAccounts,
            archiveAccount: archiveAccount,
            archiveInstitution: archiveInstitution
        )
        self.unarchiveInstitutionRule = UnarchiveInstitutionRule(
            getAccounts: getAccounts,
            unarchiveAccount: unarchiveAccount,
            unarchiveInstitution: unarchiveInstitution
        )
        self.unarchiveAccountRule = UnarchiveAccountRule(
            getAccount: getAccount,
            unarchiveAccount: unarchiveAccount,
            getInstitution: getInstitution,
            unarchiveInstitution: unarchiveInstitution
        )

        // MARK: Use Cases — Transfer
        self.transferBetweenAccounts = TransferBetweenAccounts(repository: transactionCloud)
        self.deleteTransfer = DeleteTransfer(repository: transactionCloud)
        self.updateTransfer = UpdateTransfer(repository: transactionCloud)

        // MARK: Use Cases — Transaction
        self.addTransaction = AddTransaction(repository: transactionCloud)
        self.getTransactions = GetTransactions(repository: transactionCloud)
        self.getTransaction = GetTransaction(repository: transactionCloud)
        self.updateTransaction = UpdateTransaction(repository: transactionCloud)
        self.deleteTransaction = DeleteTransaction(repository: transactionCloud, deleteDocument: deleteDocument)
        self.getTransactionsByCategory = GetTransactionsByCategory(repository: transactionCloud)
        self.getTransactionsByDateRange = GetTransactionsByDateRange(repository: transactionCloud)
        self.getAccountsSortedByRecency = GetAccountsSortedByRecency(
            getAccountsWithInstitution: getAccountsWithInstitution,
            getTransactions: getTransactions
        )

        // MARK: Cascade Rules — orchestrate cross-aggregate deletion above the features
        let getTransactionsByAccount = GetTransactionsByAccount(getTransactions: getTransactions)
        let deleteAccount = DeleteAccount(repository: accountCloud)
        self.deleteAccountRule = DeleteAccountRule(
            getTransactionsByAccount: getTransactionsByAccount,
            deleteTransaction: deleteTransaction,
            updateTransaction: updateTransaction,
            deleteAccount: deleteAccount,
            userId: userId
        )
        let deleteInstitution = DeleteInstitution(repository: institutionCloud)
        self.deleteInstitutionRule = DeleteInstitutionRule(
            getAccounts: getAccounts,
            deleteAccountRule: deleteAccountRule,
            deleteInstitution: deleteInstitution
        )
        let deleteUser = DeleteUser(repository: userCloud, deleteDocument: deleteDocument)
        let deleteUserProfile = DeleteUserProfile(
            repository: authStoring,
            deleteDocument: deleteDocument,
            userId: userId
        )
        self.deleteUserRule = DeleteUserRule(
            getInstitutions: getInstitutions,
            deleteInstitutionRule: deleteInstitutionRule,
            deleteUser: deleteUser,
            deleteUserProfile: deleteUserProfile,
            userId: userId
        )

        // MARK: Use Cases — Document
        self.uploadTransactionDocument = UploadTransactionDocument(
            documentSource: documentSource,
            transactionRepository: transactionCloud,
            userId: userId
        )
        self.uploadAvatarPhoto = UploadAvatarPhoto(
            documentSource: documentSource,
            userRepository: userCloud,
            userId: userId
        )
        self.getTransactionDocument = GetTransactionDocument()
        self.downloadImage = DownloadImage(documentSource: documentSource, networkMonitor: networkMonitor)

        // MARK: Use Cases — Charts
        self.getChartData = GetChartData(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts,
            getTransactions: getTransactions,
            userId: userId
        )

        // MARK: Use Cases — Reload
        // The cloud storings warm their Firestore cache from the server. Adding a
        // new collection later means appending its storing here — nothing else.
        self.refreshFromRemote = RefreshFromRemote(
            refreshables: [transactionCloud, accountCloud, institutionCloud]
        )
    }
}
