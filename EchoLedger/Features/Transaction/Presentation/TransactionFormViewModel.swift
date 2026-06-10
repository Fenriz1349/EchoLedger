//
//  TransactionFormViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation
import Toasty

/// Manages form state and submission logic for creating or editing a transaction.
/// The transaction total is always derived from the sum of splits — there is no separate amount field.
@MainActor
@Observable
final class TransactionFormViewModel {

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let addTransaction: AddTransaction
    private let updateTransaction: UpdateTransaction
    private let getAccountsWithInstitution: GetAccountsWithInstitution
    private let uploadTransactionDocument: UploadTransactionDocument
    private let getTransactionDocument: GetTransactionDocument
    private let deleteDocument: DeleteDocument
    private let userId: UUID
    private let authSession: AuthSession

    // MARK: Form State
    var existingTransaction: Transaction?
    var isExpense: Bool = true
    var category: TransactionCategory = .other
    var date: Date = Date()
    var label: String = ""
    var splits: [TransactionSplit] = []
    var showAddAccountForm = false
    let addAccountFormViewModel: AccountFormViewModel

    // MARK: Attachment State
    var selectedAttachmentData: Data?
    var selectedAttachmentType: AttachmentType?
    /// True when the existing attachment should be removed on the next submit.
    var removeExistingAttachment = false

    // MARK: UI State
    var availableAccounts: [AccountDisplayItem] = []
    var isLoading = false
    var errorMessage: String?
    var isSuccess = false

    /// The sum of all split amounts — used as the transaction total on submit.
    var totalAmount: Double {
        splits.map(\.amount).reduce(0, +)
    }

    /// The first available account not already used by an existing split.
    var nextAvailableAccount: Account? {
        let usedIds = Set(splits.map(\.accountId))
        return availableAccounts.first { !usedIds.contains($0.account.id) }?.account
    }

    // MARK: Computed

    /// Returns true if the form is ready to be submitted.
    var isValid: Bool {
        guard !splits.isEmpty, totalAmount > 0 else { return false }
        return Set(splits.map(\.accountId)).count == splits.count
    }

    /// Returns the trimmed label, falling back to the category name if empty.
    private var trimmedLabel: String {
        label.trimmingCharacters(in: .whitespaces).isEmpty ? category.name : label
    }

    /// Returns only initialBalance for Account creation Transaction or isUserSelectable TransactionCategory
    var categoryList: [TransactionCategory] {
        if existingTransaction?.category == .initialBalance {
            return [.initialBalance]
        }
        return TransactionCategory.allCases.filter(\.isUserSelectable)
    }

    /// Reverse isExpense for UI
    var isIncome: Bool {
        get { !isExpense }
        set { isExpense = !newValue }
    }

    /// Return true only if there is an existingTransaction wich category is initialBalance
    var isInitialBalance: Bool {
        existingTransaction?.category == .initialBalance
    }

    var isAnonymous: Bool {
        authSession.isAnonymous
    }

    /// The attachment of the transaction being edited, if any. Nil in create mode or when there is none.
    var existingDocument: DocumentResult? {
        guard !removeExistingAttachment,
              let existingTransaction, existingTransaction.attachmentURL != nil else { return nil }
        return getTransactionDocument.execute(transaction: existingTransaction)
    }

    // MARK: Init
    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - addTransaction: UseCase for creating a new transaction.
    ///   - updateTransaction: UseCase to update a existing transaction.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        addTransaction: AddTransaction,
        updateTransaction: UpdateTransaction,
        getAccountsWithInstitution: GetAccountsWithInstitution,
        uploadTransactionDocument: UploadTransactionDocument,
        getTransactionDocument: GetTransactionDocument,
        deleteDocument: DeleteDocument,
        userId: UUID,
        authSession: AuthSession,
        addAccountFormViewModel: AccountFormViewModel,
        existingTransaction: Transaction? = nil
    ) {
        self.toasty = toasty
        self.addTransaction = addTransaction
        self.updateTransaction = updateTransaction
        self.getAccountsWithInstitution = getAccountsWithInstitution
        self.uploadTransactionDocument = uploadTransactionDocument
        self.getTransactionDocument = getTransactionDocument
        self.deleteDocument = deleteDocument
        self.userId = userId
        self.authSession = authSession
        self.existingTransaction = existingTransaction
        self.addAccountFormViewModel = addAccountFormViewModel

        if let existing = self.existingTransaction {
            prefillTransaction(with: existing)
        }
    }

    // MARK: Actions

    /// Loads all available accounts and resolves their institution names.
    /// In create mode, initialises the first split automatically.
    func loadAccounts() async {
        do {
            let filter: AccountFilter = existingTransaction == nil ? .active : .all
            let items = try await getAccountsWithInstitution.execute(for: userId, filter: filter)

            if isInitialBalance,
               let accountId = splits.first?.accountId,
               let matchingItem = items.first(where: { $0.account.id == accountId }) {
                availableAccounts = [matchingItem]
            } else {
                availableAccounts = items
            }

            if existingTransaction == nil, let first = items.first {
                addSplit(for: first.account)
            }
        } catch {
            toasty.showError(error)
        }
    }

    /// Populates form fields from an existing transaction for editing.
    /// - Parameter transaction: The transaction whose values will pre-fill the form.
    private func prefillTransaction(with transaction: Transaction) {
        label = transaction.label
        isExpense = transaction.isExpense
        category = transaction.category
        splits = transaction.splits
        date = transaction.date
    }

    /// Adds a new split for the given account with a zero amount.
    func addSplit(for account: Account) {
        splits.append(TransactionSplit(accountId: account.id, amount: 0))
    }

    /// Removes a split at the given index.
    func removeSplit(at index: Int) {
        splits.remove(at: index)
    }

    /// Stores the selected document in memory. Does not upload anything.
    /// - Parameters:
    ///   - data: The selected file data.
    ///   - type: The type of the selected document.
    func selectAttachment(data: Data, type: AttachmentType) {
        selectedAttachmentData = data
        selectedAttachmentType = type
        removeExistingAttachment = false
    }

    /// Clears the pending selection (does not affect an existing attachment).
    func clearAttachment() {
        selectedAttachmentData = nil
        selectedAttachmentType = nil
    }

    /// Flags the existing attachment for removal and clears any pending selection.
    /// Nothing is deleted (Storage file or Firestore field) until `submit()` runs —
    /// closing the form without submitting leaves the attachment untouched.
    func removeExistingDocument() {
        selectedAttachmentData = nil
        selectedAttachmentType = nil
        removeExistingAttachment = true
    }

    func showSimulatorWarning() {
        toasty.showInfo(DocumentError.simulatorNotSupported.errorDescription ?? "")
    }

    /// Validates and submits the transaction.
    func submit() async {
        guard totalAmount > 0 else {
            errorMessage = TransactionError.invalidTotalAmount.localizedDescription
            return
        }
        guard !splits.isEmpty else {
            errorMessage = TransactionError.missingSplits.localizedDescription
            return
        }
        guard Set(splits.map(\.accountId)).count == splits.count else {
            errorMessage = TransactionError.redundantSplitsAccounts.localizedDescription
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            if let existingTransaction {
                let keepURL = removeExistingAttachment ? nil : existingTransaction.attachmentURL
                let keepType = removeExistingAttachment ? nil : existingTransaction.attachmentContentType
                let input = UpdateTransactionInput(
                    id: existingTransaction.id,
                    userId: userId,
                    label: trimmedLabel,
                    date: date,
                    totalAmount: totalAmount,
                    note: nil,
                    isExpense: isExpense,
                    category: category,
                    splits: splits,
                    attachmentURL: keepURL,
                    attachmentContentType: keepType
                )
                try await updateTransaction.execute(input)
                if removeExistingAttachment, let oldURL = existingTransaction.attachmentURL {
                    try? await deleteDocument.execute(urlString: oldURL)
                }
                let edited = Transaction(
                    id: existingTransaction.id,
                    userId: userId,
                    label: trimmedLabel,
                    date: date,
                    totalAmount: totalAmount,
                    note: nil,
                    isExpense: isExpense,
                    category: category,
                    splits: splits,
                    attachmentURL: keepURL,
                    attachmentContentType: keepType
                )
                await uploadPendingAttachment(to: edited)
            } else {
                let input = AddTransactionInput(
                    userId: userId,
                    label: trimmedLabel,
                    date: date,
                    totalAmount: totalAmount,
                    note: nil,
                    isExpense: isExpense,
                    category: category,
                    splits: splits
                )
                let created = try await addTransaction.execute(input)
                await uploadPendingAttachment(to: created)
            }
            isSuccess = true
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    /// Uploads the pending attachment to the given transaction, if one was selected.
    /// A failed upload does not fail the submit — it only surfaces a toast.
    private func uploadPendingAttachment(to transaction: Transaction) async {
        guard let data = selectedAttachmentData, let type = selectedAttachmentType else { return }
        do {
            try await uploadTransactionDocument.execute(data: data, attachmentType: type, transaction: transaction)
        } catch {
            toasty.showError(error)
        }
    }
}
