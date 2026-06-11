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
    var user: User
    var firstName: String
    var lastName: String
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
    
    var isFormValid: Bool {
        firstName.trimmingCharacters(in: .whitespaces).count >= 2 &&
        lastName.trimmingCharacters(in: .whitespaces).count >= 2
    }

    var isLinkFormValid: Bool {
        !linkFirstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !linkLastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Validators.isValidEmail(linkEmail) &&
        Validators.isStrongPassword(linkPassword) &&
        linkPassword == linkConfirmPassword
    }

    // MARK: Dependencies
    private let toasty: ToastyManager
    private let updateUserUseCase: UpdateUser
    private let signOutUseCase: SignOut
    private let deleteUserProfileUseCase: DeleteUserProfile
    private let linkAnonymousAccountUseCase: LinkAnonymousAccount
    private let resetPasswordUseCase: ResetPassword
    private let uploadAvatarPhotoUseCase: UploadAvatarPhoto
    private let getUserPhotoUseCase: GetUserPhoto
    private let userId: UUID
    let onSignOut: () -> Void
    let onSessionUpdated: (AuthSession) -> Void

    // MARK: Computed

    /// Shows the simulator upload blocked message via toast.
    func showSimulatorWarning() {
        toasty.showInfo(DocumentError.simulatorNotSupported.errorDescription ?? "")
    }

    var avatarDocument: DocumentResult {
        getUserPhotoUseCase.execute(user: user)
    }

    /// - Parameters:
    ///   - toasty: The shared toast notification manager.
    ///   - user: The loaded user profile.
    ///   - updateUser: Use case to update the user profile.
    ///   - signOut: Use case to sign out.
    ///   - deleteUserProfile: Use case to delete the profile.
    ///   - linkAnonymousAccount: Use case to link an anonymous account to a permanent one.
    ///   - resetPassword: Use case to send a password reset email.
    ///   - uploadAvatarPhoto: Use case to upload avatar.
    ///   - getUserPhoto: Use case to fetch user photo.
    ///   - authSession: The current authentication session.
    ///   - userId: The internal user identifier.
    ///   - daysRemainingInDemo: Number of days left in the demo session, nil if not anonymous.
    ///   - onSignOut: Closure called after sign-out or account deletion.
    ///   - onSessionUpdated: Closure called after anonymous account linking.
    init(
        toasty: ToastyManager,
        user: User,
        updateUser: UpdateUser,
        signOut: SignOut,
        deleteUserProfile: DeleteUserProfile,
        linkAnonymousAccount: LinkAnonymousAccount,
        resetPassword: ResetPassword,
        uploadAvatarPhoto: UploadAvatarPhoto,
        getUserPhoto: GetUserPhoto,
        authSession: AuthSession,
        userId: UUID,
        daysRemainingInDemo: Int?,
        onSignOut: @escaping () -> Void,
        onSessionUpdated: @escaping (AuthSession) -> Void
    ) {
        self.toasty = toasty
        self.user = user
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.updateUserUseCase = updateUser
        self.signOutUseCase = signOut
        self.deleteUserProfileUseCase = deleteUserProfile
        self.linkAnonymousAccountUseCase = linkAnonymousAccount
        self.resetPasswordUseCase = resetPassword
        self.uploadAvatarPhotoUseCase = uploadAvatarPhoto
        self.getUserPhotoUseCase = getUserPhoto
        self.authSession = authSession
        self.userId = userId
        self.daysRemainingInDemo = daysRemainingInDemo
        self.onSignOut = onSignOut
        self.onSessionUpdated = onSessionUpdated
    }

    /// Enters edit mode and pre-fills fields with the current user values.
    func startEditing() {
        firstName = user.firstName
        lastName = user.lastName
        firstNameEditState = .neutral
        lastNameEditState = .neutral
        isEditing = true
    }

    /// Cancels edit mode and restores fields to the current saved values.
    func cancelEdit() {
        firstName = user.firstName
        lastName = user.lastName
        firstNameEditState = .neutral
        lastNameEditState = .neutral
        isEditing = false
    }

    /// Updates the user's first and last name locally and remotely, then exits edit mode on success.
    func updateProfile() async {
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespaces)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespaces)
        guard !trimmedFirst.isEmpty else { firstNameEditState = .invalid; return }
        guard !trimmedLast.isEmpty else { lastNameEditState = .invalid; return }
        isLoading = true
        defer { isLoading = false }
        do {
            let input = UpdateUserInput(id: user.id,
                                        firstName: trimmedFirst,
                                        lastName: trimmedLast,
                                        email: user.email,
                                        photoURL: user.photoURL)
            try await updateUserUseCase.execute(input)
            user = User(id: user.id,
                        displayName: "\(trimmedFirst)|\(trimmedLast)",
                        email: user.email,
                        photoURL: user.photoURL)
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
    func deleteUserProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await deleteUserProfileUseCase.execute()
            toasty.showInfo("Compte supprimé.")
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

    /// Uploads new avatar data to Firebase Storage.
    func uploadAvatar(data: Data) async {
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }
        do {
            let photoURL = try await uploadAvatarPhotoUseCase.execute(data: data)
            user = User(id: user.id, displayName: user.displayName, email: user.email, photoURL: photoURL)
            toasty.showSuccess("Photo mise à jour.")
        } catch {
            toasty.showError(error)
        }
    }

    /// Removes the current avatar by setting photoURL to nil.
    func removeAvatar() async {
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }
        do {
            let input = UpdateUserInput(
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                photoURL: nil
            )
            try await updateUserUseCase.execute(input)
            user = User(id: user.id, displayName: user.displayName, email: user.email, photoURL: nil)
            toasty.showSuccess("Photo supprimée.")
        } catch {
            toasty.showError(error)
        }
    }

    /// Sends a password reset email to the current user's email address.
    func sendPasswordReset() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await resetPasswordUseCase.execute(email: user.email)
            toasty.showSuccess("Email de réinitialisation envoyé.")
        } catch {
            toasty.showError(error)
        }
    }
}
