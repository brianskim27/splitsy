import Foundation
import SwiftUI
import Combine

enum AuthState {
    case signedOut
    case signedIn
    case loading
}

class AuthenticationManager: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private func checkInitialAuthState() {
        // Check if there's a current user in Firebase Auth directly
        if let currentUser = firebaseService.auth.currentUser {
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
                    // Only update state if we're not in the initial loading phase
                    if self?.authState != .loading {
                        self?.authState = isAuthenticated ? .signedIn : .signedOut
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
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, name: String) {
        Task {
            await firebaseService.signUp(email: email, password: password, name: name)
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            await firebaseService.signIn(email: email, password: password)
        }
    }
    
    func signOut() {
        Task {
            await firebaseService.signOut()
        }
    }
    
    func resetPassword(email: String) {
        Task {
            await firebaseService.resetPassword(email: email)
        }
    }
    
    // MARK: - Firebase Helper Methods
    
    func sendEmailVerification() {
        Task {
            await firebaseService.sendEmailVerification()
        }
    }
    
    func saveSplits(_ splits: [Split]) {
        Task {
            await firebaseService.saveSplits(splits)
        }
    }
    
    func loadSplits() async -> [Split] {
        return await firebaseService.loadSplits()
    }
    
    // MARK: - Social Login Methods
    
    /*
    func signInWithApple() {
        Task {
            await firebaseService.signInWithApple()
        }
    }
    */
    
    func signInWithGoogle() {
        Task {
            await firebaseService.signInWithGoogle()
        }
    }
}
