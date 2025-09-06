import Foundation
import SwiftUI
import Combine

enum AuthState {
    case signedOut
    case signedIn
    case loading
    case needsEmailVerification
    case needsUsernameSetup
}

@MainActor
class AuthenticationManager: ObservableObject, @unchecked Sendable {
    @Published var authState: AuthState = .loading
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // Callback for when user signs out
    var onSignOut: (() -> Void)?
    
    private func checkInitialAuthState() {
        // Only set initial auth state if we're still in loading state
        // This prevents overriding states set by signup flows (needsEmailVerification, needsParentalConsent, etc.)
        guard authState == .loading else { return }
        
        // Check if there's a current user in Firebase Auth directly
        if firebaseService.auth.currentUser != nil {
            authState = .signedIn
        } else if firebaseService.isAuthenticated {
            authState = .signedIn
        } else {
            authState = .signedOut
        }
    }
    
    init() {
        // Set initial loading state
        authState = .loading
        
        // Listen to Firebase authentication state changes
        firebaseService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                DispatchQueue.main.async {
                    if let self = self {
                        // If user becomes authenticated and we're in loading state, update to signed in
                        if isAuthenticated && self.authState == .loading {
                            self.authState = .signedIn
                        }
                        // If user becomes unauthenticated and we're not in a special state, update to signed out
                        else if !isAuthenticated && 
                                self.authState != .needsEmailVerification && 
                                self.authState != .needsUsernameSetup {
                            self.authState = .signedOut
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        // Check current Firebase auth state after a minimum loading time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.checkInitialAuthState()
        }
        
        // Also check again after a longer delay to ensure Firebase is fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.checkInitialAuthState()
        }
        
        firebaseService.$currentUser
            .sink { [weak self] user in
                DispatchQueue.main.async {
                    self?.currentUser = user
                }
            }
            .store(in: &cancellables)
        
        firebaseService.$isLoading
            .sink { [weak self] isLoading in
                DispatchQueue.main.async {
                    self?.isLoading = isLoading
                }
            }
            .store(in: &cancellables)
        
        firebaseService.$errorMessage
            .sink { [weak self] errorMessage in
                DispatchQueue.main.async {
                    self?.errorMessage = errorMessage
                }
            }
            .store(in: &cancellables)
        
        firebaseService.$authState
            .sink { [weak self] authState in
                DispatchQueue.main.async {
                    self?.authState = authState
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, name: String) {
        Task {
            await firebaseService.signUp(email: email, password: password, name: name)
        }
    }
    
    func signUpWithUsername(email: String, password: String, name: String, username: String) async {
        await firebaseService.signUpWithUsername(email: email, password: password, name: name, username: username)
    }
    
    
    func checkUsernameAvailability(_ username: String) async -> Bool {
        return await firebaseService.checkUsernameAvailability(username)
    }
    
    func checkEmailAvailability(_ email: String) async -> Bool {
        return await firebaseService.checkEmailAvailability(email)
    }
    
    func updateProfile(name: String, username: String?) async {
        await firebaseService.updateProfile(name: name, username: username)
    }
    
    func uploadProfilePicture(_ image: UIImage) async {
        await firebaseService.uploadProfilePicture(image)
    }
    
    func removeProfilePicture() async {
        await firebaseService.removeProfilePicture()
    }
    
    func isEmailVerified() -> Bool {
        return firebaseService.auth.currentUser?.isEmailVerified == true
    }
    
    func signIn(email: String, password: String) {
        Task {
            await firebaseService.signIn(email: email, password: password)
        }
    }
    
    func signIn(emailOrUsername: String, password: String) {
        Task {
            await firebaseService.signIn(emailOrUsername: emailOrUsername, password: password)
        }
    }
    
    func signOut() {
        Task {
            await firebaseService.signOut()
            // Call the sign out callback to clear user data
            DispatchQueue.main.async {
                self.onSignOut?()
            }
        }
    }
    
    func resetPassword(email: String) {
        Task {
            await firebaseService.resetPassword(email: email)
        }
    }
    
    func deleteAccount() async -> Bool {
        return await firebaseService.deleteAccount()
    }
    
    
    func sendEmailVerification() async {
        await firebaseService.sendEmailVerification()
    }
    
    func checkEmailVerificationStatus() async -> Bool {
        return await firebaseService.checkEmailVerificationStatus()
    }
    
    func resendEmailVerification() async {
        await firebaseService.resendEmailVerification()
    }
    
    
    // MARK: - Firebase Helper Methods
    
    func saveSplits(_ splits: [Split]) {
        Task {
            await firebaseService.saveSplits(splits)
        }
    }
    
    func loadSplits() async -> [Split] {
        return await firebaseService.loadSplits()
    }
    
    // MARK: - Social Login Methods
    
    
    func signInWithGoogle() {
        Task {
            await firebaseService.signInWithGoogle()
        }
    }
    
    func completeUsernameSetup(username: String) {
        Task {
            await firebaseService.completeUsernameSetup(username: username)
        }
    }
    
    func cancelIncompleteSignup() {
        Task {
            await firebaseService.cancelIncompleteSignup()
        }
    }
    
    func updateUserCurrency(_ currencyCode: String) async {
        guard var user = currentUser else { return }
        
        user.preferredCurrency = currencyCode
        
        do {
            try await firebaseService.updateUser(user)
            let updatedUser = user // Capture the value before the async operation
            await MainActor.run {
                self.currentUser = updatedUser
            }
        } catch {
        }
    }
}
