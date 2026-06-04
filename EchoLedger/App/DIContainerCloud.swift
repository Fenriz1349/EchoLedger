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

    // MARK: Storings
    let userStoring: UserProviding
    let institutionStoring: InstitutionProviding
    let accountStoring: AccountProviding
    let transactionStoring: TransactionProviding

    // MARK: Use Cases — Auth
    let signOut: SignOut
    let deleteUserAccount: DeleteUserAccount
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
    let archiveInstitution: ArchiveInstitution
    let unarchiveInstitution: UnarchiveInstitution
    let deleteInstitution: DeleteInstitution

    // MARK: Use Cases — Account
    let addAccount: AddAccount
    let getAccounts: GetAccounts
    let getAccount: GetAccount
    let updateAccount: UpdateAccount
    let archiveAccount: ArchiveAccount
    let unarchiveAccount: UnarchiveAccount
    let getAccountBalance: GetAccountBalance
    let getAccountsWithInstitution: GetAccountsWithInstitution
    let deleteAccount: DeleteAccount

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

    // MARK: Use Cases — Document
    let uploadTransactionDocument: UploadTransactionDocument
    let uploadAvatarPhoto: UploadAvatarPhoto
    let deleteDocument: DeleteDocument
    let getTransactionDocument: GetTransactionDocument
    let getUserPhoto: GetUserPhoto

    // MARK: Init

    init(userId: UUID, toasty: ToastyManager, authStoring: AuthProviding,
         authSession: AuthSession) {
        self.userId = userId
        self.toasty = toasty
        self.authStoring = authStoring
        self.authSession = authSession

        let firebaseUID = Auth.auth().currentUser?.uid ?? ""

        // MARK: Cloud Storings
        let userCloud = UserCloudStoring(remote: userRemote, userId: userId, firebaseUID: firebaseUID)
        let institutionCloud = InstitutionCloudStoring(remote: institutionRemote, userId: userId)
        let accountCloud = AccountCloudStoring(remote: accountRemote, userId: userId)
        let transactionCloud = TransactionCloudStoring(remote: transactionRemote, userId: userId)

        self.userStoring = userCloud
        self.institutionStoring = institutionCloud
        self.accountStoring = accountCloud
        self.transactionStoring = transactionCloud

        // MARK: Use Cases — Auth
        self.signOut = SignOut(repository: authStoring)
        self.deleteUserAccount = DeleteUserAccount(repository: authStoring)
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
        self.archiveInstitution = ArchiveInstitution(institutionRepository: institutionCloud,
                                                     accountRepository: accountCloud)
        self.unarchiveInstitution = UnarchiveInstitution(institutionRepository: institutionCloud,
                                                         accountRepository: accountCloud)

        // MARK: Use Cases — Account
        self.addAccount = AddAccount(repository: accountCloud)
        self.getAccounts = GetAccounts(repository: accountCloud)
        self.getAccount = GetAccount(repository: accountCloud)
        self.updateAccount = UpdateAccount(repository: accountCloud)
        self.archiveAccount = ArchiveAccount(repository: accountCloud)
        self.unarchiveAccount = UnarchiveAccount(accountRepository: accountCloud,
                                                  institutionRepository: institutionCloud)
        self.getAccountBalance = GetAccountBalance(
            accountRepository: accountCloud,
            transactionRepository: transactionCloud
        )
        self.getAccountsWithInstitution = GetAccountsWithInstitution(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts
        )
        self.deleteAccount = DeleteAccount(
            accountRepository: accountCloud,
            transactionRepository: transactionCloud,
            userId: userId
        )
        self.deleteInstitution = DeleteInstitution(
            repository: institutionCloud,
            getAccounts: getAccounts,
            deleteAccount: deleteAccount
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
        self.deleteTransaction = DeleteTransaction(repository: transactionCloud)
        self.getTransactionsByCategory = GetTransactionsByCategory(repository: transactionCloud)
        self.getTransactionsByDateRange = GetTransactionsByDateRange(repository: transactionCloud)

        // MARK: Use Cases — Document
        let documentSource = DocumentRemoteSource()
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
        self.deleteDocument = DeleteDocument(documentSource: documentSource)
        self.getTransactionDocument = GetTransactionDocument()
        self.getUserPhoto = GetUserPhoto()
    }
}
