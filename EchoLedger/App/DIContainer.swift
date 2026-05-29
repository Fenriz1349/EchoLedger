//
//  DIContainer.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import SwiftData
import Toasty

/// Assembles and provides all dependencies for the application.
/// Acts as the single source of truth for dependency injection.
@MainActor
@Observable
final class DIContainer {

    // MARK: SwiftData Stack
    let modelContainer: ModelContainer

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: Local Sources
    private let userLocalSource: UserLocalSource
    private let institutionLocalSource: InstitutionLocalSource
    private let accountLocalSource: AccountLocalSource
    private let transactionLocalSource: TransactionLocalSource

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

    // MARK: Sync
    let syncManager: SyncManager

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

    /// Creates the container with all resolved dependencies.
    /// - Parameters:
    ///   - userId: The stable UUID derived from the authentication session.
    ///   - toasty: The shared toast notification manager.
    ///   - authStoring: The authentication provider used for sign-out and account deletion.
    ///   - authSession: The current authentication session.
    ///   - inMemory: If true, SwiftData stores data in memory only. Defaults to false.
    init(userId: UUID, toasty: ToastyManager, authStoring: AuthProviding,
         authSession: AuthSession, inMemory: Bool = false) {
        self.userId = userId
        self.toasty = toasty
        self.authStoring = authStoring
        self.authSession = authSession

        // MARK: SwiftData Stack
        let schema = Schema([
            UserModel.self,
            InstitutionModel.self,
            AccountModel.self,
            TransactionModel.self,
            TransactionSplitModel.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        let context = modelContainer.mainContext

        // MARK: Local Sources
        let userLocal = UserLocalSource(context: context)
        let institutionLocal = InstitutionLocalSource(context: context)
        let accountLocal = AccountLocalSource(context: context)
        let transactionLocal = TransactionLocalSource(context: context)

        self.userLocalSource = userLocal
        self.institutionLocalSource = institutionLocal
        self.accountLocalSource = accountLocal
        self.transactionLocalSource = transactionLocal

        // MARK: Storings
        let userStore = UserStoring(local: userLocal, remote: userRemote, userId: userId)
        let institutionStore = InstitutionStoring(local: institutionLocal,
                                                  remote: institutionRemote, userId: userId)
        let accountStore = AccountStoring(local: accountLocal,
                                          remote: accountRemote, userId: userId)
        let transactionStore = TransactionStoring(local: transactionLocal,
                                                  remote: transactionRemote, userId: userId)

        self.userStoring = userStore
        self.institutionStoring = institutionStore
        self.accountStoring = accountStore
        self.transactionStoring = transactionStore

        // MARK: Sync
        self.syncManager = SyncManager(
            userId: userId,
            institutionRemote: institutionRemote,
            accountRemote: accountRemote,
            transactionRemote: transactionRemote,
            institutionLocal: institutionLocal,
            accountLocal: accountLocal,
            transactionLocal: transactionLocal
        )

        // MARK: Use Cases — Auth
        self.signOut = SignOut(repository: authStoring)
        self.deleteUserAccount = DeleteUserAccount(repository: authStoring)
        self.linkAnonymousAccount = LinkAnonymousAccount(repository: authStoring)
        self.resetPassword = ResetPassword(repository: authStoring)

        // MARK: Use Cases — User
        self.getCurrentUser = GetCurrentUser(repository: userStore)
        self.updateUser = UpdateUser(repository: userStore)

        // MARK: Use Cases — Institution
        self.addInstitution = AddInstitution(repository: institutionStore)
        self.getInstitutions = GetInstitutions(repository: institutionStore)
        self.getInstitution = GetInstitution(repository: institutionStore)
        self.updateInstitution = UpdateInstitution(repository: institutionStore)
        self.archiveInstitution = ArchiveInstitution(institutionRepository: institutionStore,
                                                     accountRepository: accountStore)
        self.unarchiveInstitution = UnarchiveInstitution(institutionRepository: institutionStore,
                                                         accountRepository: accountStore)

        // MARK: Use Cases — Account
        self.addAccount = AddAccount(repository: accountStore)
        self.getAccounts = GetAccounts(repository: accountStore)
        self.getAccount = GetAccount(repository: accountStore)
        self.updateAccount = UpdateAccount(repository: accountStore)
        self.archiveAccount = ArchiveAccount(repository: accountStore)
        self.unarchiveAccount = UnarchiveAccount(accountRepository: accountStore,
                                                  institutionRepository: institutionStore)
        self.getAccountBalance = GetAccountBalance(
            accountRepository: accountStore,
            transactionRepository: transactionStore
        )
        self.getAccountsWithInstitution = GetAccountsWithInstitution(
            getInstitutions: getInstitutions,
            getAccounts: getAccounts
        )
        self.deleteAccount = DeleteAccount(
            accountRepository: accountStore,
            transactionRepository: transactionStore,
            userId: userId
        )
        self.deleteInstitution = DeleteInstitution(
            repository: institutionStore,
            getAccounts: getAccounts,
            deleteAccount: deleteAccount
        )

        // MARK: Use Cases — Transfer
        self.transferBetweenAccounts = TransferBetweenAccounts(repository: transactionStore)
        self.deleteTransfer = DeleteTransfer(repository: transactionStore)
        self.updateTransfer = UpdateTransfer(repository: transactionStore)

        // MARK: Use Cases — Transaction
        self.addTransaction = AddTransaction(repository: transactionStore)
        self.getTransactions = GetTransactions(repository: transactionStore)
        self.getTransaction = GetTransaction(repository: transactionStore)
        self.updateTransaction = UpdateTransaction(repository: transactionStore)
        self.deleteTransaction = DeleteTransaction(repository: transactionStore)
        self.getTransactionsByCategory = GetTransactionsByCategory(repository: transactionStore)
        self.getTransactionsByDateRange = GetTransactionsByDateRange(repository: transactionStore)

        // MARK: Use Cases — Document
        let documentSource = DocumentRemoteSource()
        self.uploadTransactionDocument = UploadTransactionDocument(
            documentSource: documentSource,
            transactionRepository: transactionStore,
            userId: userId
        )
        self.uploadAvatarPhoto = UploadAvatarPhoto(
            documentSource: documentSource,
            userRepository: userStore,
            userId: userId
        )
        self.deleteDocument = DeleteDocument(documentSource: documentSource)
        self.getTransactionDocument = GetTransactionDocument()
        self.getUserPhoto = GetUserPhoto()
    }
}
