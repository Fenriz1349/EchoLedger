//
//  UserProfileViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation
import CustomTextFields
import Toasty

/// Manages state and logic for the user profile screen.
@Observable
@MainActor
final class UserProfileViewModel {

    // MARK: User State
    var user: User?
    var firstName: String = ""
    var lastName: String = ""
    var firstNameEditState: ValidationState = .neutral
    var lastNameEditState: ValidationState = .neutral

    // MARK: Link Form
    var linkFirstName: String = ""
    var linkLastName: String = ""
    var linkEmail: String = ""
    var linkPassword: String = ""
    var linkConfirmPassword: String = ""
    var linkFirstNameState: ValidationState = .neutral
    var linkLastNameState: ValidationState = .neutral
    var linkEmailState: ValidationState = .neutral
    var linkPasswordState: ValidationState = .neutral
    var linkConfirmPasswordState: ValidationState = .neutral

    // MARK: UI State
    var isLoading: Bool = false
    var isEditing: Bool = false
    var showDeleteAlert: Bool = false
    var isUploadingAvatar: Bool = false
    private(set) var authSession: AuthSession

    // MARK: Computed
    var isAnonymous: Bool { authSession.isAnonymous }
    let daysRemainingInDemo: Int?

    var isLinkFormValid: Bool {
        !linkFirstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !linkLastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Validators.isValidEmail(linkEmail) &&
        Validators.isStrongPassword(linkPassword) &&
        linkPassword == linkConfirmPassword
    }

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let getCurrentUserUseCase: GetCurrentUser
    private let updateUserUseCase: UpdateUser
    private let signOutUseCase: SignOut
    private let deleteUserAccountUseCase: DeleteUserAccount
    private let linkAnonymousAccountUseCase: LinkAnonymousAccount
    private let resetPasswordUseCase: ResetPassword
    private let uploadAvatarPhotoUseCase: UploadAvatarPhoto
    private let getUserPhotoUseCase: GetUserPhoto
    private let userStoring: UserProviding
    private let userId: UUID
    let onSignOut: () -> Void
    let onSessionUpdated: (AuthSession) -> Void

    // MARK: Computed

    /// Shows the simulator upload blocked message via toast.
    func showSimulatorWarning() {
        toasty.showInfo(DocumentError.simulatorNotSupported.errorDescription ?? "")
    }

    var avatarDocument: DocumentResult {
        guard let currentUser = user else {
            return DocumentResult(urlString: nil, attachmentType: nil, placeholder: .avatar)
        }
        return getUserPhotoUseCase.execute(user: currentUser)
    }

    /// - Parameters:
    ///   - toasty: The shared toast notification manager.
    ///   - getCurrentUser: Use case to fetch the current user profile.
    ///   - updateUser: Use case to update the user profile.
    ///   - signOut: Use case to sign out.
    ///   - deleteUserAccount: Use case to delete the account.
    ///   - linkAnonymousAccount: Use case to link an anonymous account to a permanent one.
    ///   - resetPassword: Use case to send a password reset email.
    ///   - userStoring: User repository for local cascade deletion.
    ///   - authSession: The current authentication session.
    ///   - userId: The internal user identifier.
    ///   - daysRemainingInDemo: Number of days left in the demo session, nil if not anonymous.
    ///   - onSignOut: Closure called after sign-out or account deletion.
    ///   - onSessionUpdated: Closure called after anonymous account linking.
    init(
        toasty: ToastyManager,
        getCurrentUser: GetCurrentUser,
        updateUser: UpdateUser,
        signOut: SignOut,
        deleteUserAccount: DeleteUserAccount,
        linkAnonymousAccount: LinkAnonymousAccount,
        resetPassword: ResetPassword,
        uploadAvatarPhoto: UploadAvatarPhoto,
        getUserPhoto: GetUserPhoto,
        userStoring: UserProviding,
        authSession: AuthSession,
        userId: UUID,
        daysRemainingInDemo: Int?,
        onSignOut: @escaping () -> Void,
        onSessionUpdated: @escaping (AuthSession) -> Void
    ) {
        self.toasty = toasty
        self.getCurrentUserUseCase = getCurrentUser
        self.updateUserUseCase = updateUser
        self.signOutUseCase = signOut
        self.deleteUserAccountUseCase = deleteUserAccount
        self.linkAnonymousAccountUseCase = linkAnonymousAccount
        self.resetPasswordUseCase = resetPassword
        self.uploadAvatarPhotoUseCase = uploadAvatarPhoto
        self.getUserPhotoUseCase = getUserPhoto
        self.userStoring = userStoring
        self.authSession = authSession
        self.userId = userId
        self.daysRemainingInDemo = daysRemainingInDemo
        self.onSignOut = onSignOut
        self.onSessionUpdated = onSessionUpdated
    }

    /// Loads the current user profile from local storage.
    func load() async {
        do {
            let loadedUser = try await getCurrentUserUseCase.execute()
            user = loadedUser
            firstName = loadedUser.firstName
            lastName = loadedUser.lastName
        } catch {
            // Anonymous users have no profile — expected
        }
    }

    /// Enters edit mode and pre-fills fields with the current user values.
    func startEditing() {
        guard let currentUser = user else { return }
        firstName = currentUser.firstName
        lastName = currentUser.lastName
        firstNameEditState = .neutral
        lastNameEditState = .neutral
        isEditing = true
    }

    /// Cancels edit mode and restores fields to the current saved values.
    func cancelEdit() {
        guard let currentUser = user else { return }
        firstName = currentUser.firstName
        lastName = currentUser.lastName
        firstNameEditState = .neutral
        lastNameEditState = .neutral
        isEditing = false
    }

    /// Updates the user's first and last name locally and remotely, then exits edit mode on success.
    func updateProfile() async {
        guard let currentUser = user else { return }
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespaces)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespaces)
        guard !trimmedFirst.isEmpty else { firstNameEditState = .invalid; return }
        guard !trimmedLast.isEmpty else { lastNameEditState = .invalid; return }
        isLoading = true
        defer { isLoading = false }
        do {
            let input = UpdateUserInput(id: currentUser.id,
                                        firstName: trimmedFirst,
                                        lastName: trimmedLast,
                                        email: currentUser.email,
                                        photoURL: currentUser.photoURL)
            try await updateUserUseCase.execute(input)
            user = User(id: currentUser.id,
                        displayName: "\(trimmedFirst)|\(trimmedLast)",
                        email: currentUser.email,
                        photoURL: currentUser.photoURL)
            isEditing = false
            toasty.showSuccess("Profil mis à jour.")
        } catch {
            toasty.showError(error)
        }
    }

    /// Signs out and clears the local session.
    func signOut() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await signOutUseCase.execute()
            onSignOut()
        } catch {
            toasty.showError(error)
        }
    }

    /// Deletes the Firebase account, Firestore document, and local SwiftData data.
    func deleteUserAccount() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await deleteUserAccountUseCase.execute()
            try await userStoring.delete(by: userId)
            onSignOut()
        } catch {
            toasty.showError(error)
        }
    }

    /// Links the anonymous account to a permanent email/password account.
    func linkAccount() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await linkAnonymousAccountUseCase.execute(
                email: linkEmail,
                password: linkPassword,
                firstName: linkFirstName,
                lastName: linkLastName
            )
            authSession = session
            user = User(id: session.userId, displayName: "\(linkFirstName)|\(linkLastName)", email: linkEmail)
            onSessionUpdated(session)
            toasty.showSuccess("Compte créé avec succès.")
        } catch {
            toasty.showError(error)
        }
    }

    /// Uploads new avatar data to Firebase Storage and refreshes the user profile.
    func uploadAvatar(data: Data) async {
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }
        do {
            _ = try await uploadAvatarPhotoUseCase.execute(data: data)
            await load()
            toasty.showSuccess("Photo mise à jour.")
        } catch {
            toasty.showError(error)
        }
    }

    /// Removes the current avatar by setting photoURL to nil.
    func removeAvatar() async {
        guard let currentUser = user else { return }
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }
        do {
            let input = UpdateUserInput(
                id: currentUser.id,
                firstName: currentUser.firstName,
                lastName: currentUser.lastName,
                email: currentUser.email,
                photoURL: nil
            )
            try await updateUserUseCase.execute(input)
            await load()
            toasty.showSuccess("Photo supprimée.")
        } catch {
            toasty.showError(error)
        }
    }

    /// Sends a password reset email to the current user's email address.
    func sendPasswordReset() async {
        guard let email = user?.email else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await resetPasswordUseCase.execute(email: email)
            toasty.showSuccess("Email de réinitialisation envoyé.")
        } catch {
            toasty.showError(error)
        }
    }
}
