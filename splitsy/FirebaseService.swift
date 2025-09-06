import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import AuthenticationServices
import GoogleSignIn
import SwiftUI

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var authState: AuthState = .loading
    
    private init() {
        // Configure Firebase settings for better network handling
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: NSNumber(value: FirestoreCacheSizeUnlimited))
        db.settings = settings
        
        // Check initial authentication state immediately
        checkInitialAuthState()
        
        // Listen for authentication state changes
        _ = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let firebaseUser = user {
                    self?.handleUserSignIn(firebaseUser)
                } else {
                    self?.handleUserSignOut()
                }
            }
        }
    }
    
    private func checkInitialAuthState() {
        if let currentUser = auth.currentUser {
            handleUserSignIn(currentUser)
        } else {
            DispatchQueue.main.async {
                self.authState = .signedOut
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, name: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Check if email is already taken with retry logic
            let isEmailAvailable = await checkEmailAvailabilityWithRetry(email)
            guard isEmailAvailable else {
                DispatchQueue.main.async {
                    self.errorMessage = "This email is already registered. Please use a different email or sign in instead."
                    self.isLoading = false
                }
                return
            }
            
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // Create user profile in Firestore
            let user = User(
                id: authResult.user.uid,
                email: email.lowercased(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                username: "", // Will be set later
                createdAt: Date()
            )
            
            try await saveUserToFirestore(user)
            
            // Send email verification
            try await authResult.user.sendEmailVerification()
            print("✅ FirebaseService: Email verification sent to \(email)")
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = false // Not fully authenticated until email is verified
                self.authState = .needsEmailVerification
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                // Check if the error is "email already exists" in Firebase Auth
                if let authError = error as NSError?, authError.code == 17007 {
                    self.errorMessage = "This email is already registered. Please use a different email or sign in instead."
                } else {
                    self.errorMessage = self.getErrorMessage(from: error)
                }
                self.isLoading = false
            }
        }
    }
    
    func signUpWithUsername(email: String, password: String, name: String, username: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Check if email is already taken with retry logic
            let isEmailAvailable = await checkEmailAvailabilityWithRetry(email)
            guard isEmailAvailable else {
                DispatchQueue.main.async {
                    self.errorMessage = "This email is already registered. Please use a different email or sign in instead."
                    self.isLoading = false
                }
                return
            }
            
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // Create user profile in Firestore
            let user = User(
                id: authResult.user.uid,
                email: email.lowercased(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username.lowercased(),
                createdAt: Date()
            )
            
            try await saveUserToFirestore(user)
            try await reserveUsername(username: username.lowercased(), userId: authResult.user.uid)
            
            // Send email verification
            try await authResult.user.sendEmailVerification()
            print("✅ FirebaseService: Email verification sent to \(email)")
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = false // Not fully authenticated until email is verified
                self.authState = .needsEmailVerification
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                // Check if the error is "email already exists" in Firebase Auth
                if let authError = error as NSError?, authError.code == 17007 {
                    self.errorMessage = "This email is already registered. Please use a different email or sign in instead."
                } else {
                    self.errorMessage = self.getErrorMessage(from: error)
                }
                self.isLoading = false
            }
        }
    }
    
    
    func checkUsernameAvailability(_ username: String) async -> Bool {
        do {
            let usernameDoc = try await db.collection("usernames").document(username.lowercased()).getDocument()
            return !usernameDoc.exists
        } catch {
            return false
        }
    }
    
    func checkEmailAvailability(_ email: String) async -> Bool {
        do {
            // Check if email exists in Firestore users collection
            let emailQuery = try await db.collection("users")
                .whereField("email", isEqualTo: email.lowercased())
                .limit(to: 1)
                .getDocuments()
            
            // If email exists in Firestore, it's not available
            if !emailQuery.documents.isEmpty {
                return false
            }
            
            // Since fetchSignInMethods is deprecated and has security implications,
            // we'll rely primarily on Firestore checking for now.
            // The actual Firebase Auth check will happen during signup attempt.
            // This is more secure and avoids deprecated methods.
            return true
            
        } catch {
            print("❌ FirebaseService: Error checking email availability in Firestore: \(error.localizedDescription)")
            return false
        }
    }
    
    func updateProfile(name: String, username: String?) async {
        guard let currentUser = self.currentUser else { return }
        
        do {
            var updates: [String: Any] = ["name": name]
            
            if let newUsername = username, newUsername != currentUser.username {
                // Check if username is available
                let isAvailable = await checkUsernameAvailability(newUsername)
                if !isAvailable {
                    throw NSError(domain: "FirebaseService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Username is already taken"])
                }
                
                // Release old username
                if !currentUser.username.isEmpty {
                    try await db.collection("usernames").document(currentUser.username).delete()
                }
                
                // Reserve new username
                try await reserveUsername(username: newUsername.lowercased(), userId: currentUser.id)
                updates["username"] = newUsername.lowercased()
                updates["usernameLastChanged"] = Timestamp(date: Date())
            }
            
            try await db.collection("users").document(currentUser.id).updateData(updates)
            
            // Update local user object
            let updatedUser = User(
                id: currentUser.id,
                email: currentUser.email,
                name: name,
                username: username ?? currentUser.username,
                createdAt: currentUser.createdAt,
                usernameLastChanged: username != currentUser.username ? Date() : currentUser.usernameLastChanged,
                profilePictureURL: currentUser.profilePictureURL,
                assignedItemIDs: currentUser.assignedItemIDs,
                preferredCurrency: currentUser.preferredCurrency
            )
            
            DispatchQueue.main.async {
                self.currentUser = updatedUser
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func reserveUsername(username: String, userId: String) async throws {
        try await db.collection("usernames").document(username.lowercased()).setData([
            "userId": userId,
            "reservedAt": Timestamp(date: Date())
        ])
    }
    
    func signIn(email: String, password: String) async {
        await signIn(emailOrUsername: email, password: password)
    }
    
    func signIn(emailOrUsername: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // First, try to sign in directly (in case it's an email)
            do {
                _ = try await auth.signIn(withEmail: emailOrUsername, password: password)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
                
            } catch {
                // If direct sign-in fails, check if it's a username
                if emailOrUsername.contains("@") {
                    // It was an email, so the error is legitimate
                    throw error
                }
                
                // Try to find user by username
                let userEmail = try await findUserEmailByUsername(emailOrUsername)
                _ = try await auth.signIn(withEmail: userEmail, password: password)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = self.getErrorMessage(from: error)
                self.isLoading = false
            }
        }
    }
    
    private func findUserEmailByUsername(_ username: String) async throws -> String {
        let usernameDoc = try await db.collection("usernames").document(username.lowercased()).getDocument()
        
        guard usernameDoc.exists,
              let userId = usernameDoc.data()?["userId"] as? String else {
            throw NSError(domain: "FirebaseService", code: 6, userInfo: [NSLocalizedDescriptionKey: "Username not found"])
        }
        
        let userDoc = try await db.collection("users").document(userId).getDocument()
        
        guard let userData = userDoc.data(),
              let email = userData["email"] as? String else {
            throw NSError(domain: "FirebaseService", code: 7, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
        }
        
        return email
    }
    
    func signOut() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            try auth.signOut()
            // User will be handled by the auth state listener
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func resetPassword(email: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            
            DispatchQueue.main.async {
                self.errorMessage = "Password reset email sent to \(email)"
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = self.getErrorMessage(from: error)
                self.isLoading = false
            }
        }
    }
    
    func sendEmailVerification() async {
        guard let user = auth.currentUser else { 
            print("❌ FirebaseService: No current user for email verification")
            return 
        }
        
        do {
            try await user.sendEmailVerification()
            print("✅ FirebaseService: Email verification sent successfully")
        } catch {
            print("❌ FirebaseService: Failed to send verification email: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to send verification email: \(error.localizedDescription)"
            }
        }
    }
    
    func checkEmailVerificationStatus() async -> Bool {
        guard let user = auth.currentUser else { 
            print("❌ FirebaseService: No current user to check verification status")
            return false 
        }
        
        do {
            try await user.reload()
            let isVerified = user.isEmailVerified
            print("📧 FirebaseService: Email verification status: \(isVerified ? "Verified" : "Not verified")")
            return isVerified
        } catch {
            print("❌ FirebaseService: Failed to check email verification status: \(error.localizedDescription)")
            return false
        }
    }
    
    func resendEmailVerification() async {
        await sendEmailVerification()
    }
    
    
    func deleteAccount() async -> Bool {
        print("🗑️ FirebaseService: Starting account deletion process")
        
        guard let currentUser = self.currentUser else {
            print("❌ FirebaseService: No current user found for deletion")
            DispatchQueue.main.async {
                self.errorMessage = "No user account found to delete"
            }
            return false
        }
        
        print("✅ FirebaseService: Current user found for deletion - \(currentUser.id)")
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // 1. Delete user's profile picture from Storage (if exists)
            if currentUser.profilePictureURL != nil {
                print("🔥 FirebaseService: Deleting profile picture from Storage")
                let storageRef = storage.reference().child("profile_pictures/\(currentUser.id).jpg")
                try? await storageRef.delete() // Use try? to not fail if image doesn't exist
                print("✅ FirebaseService: Profile picture deleted from Storage")
            }
            
            // 2. Delete user's splits from Firestore
            print("🔥 FirebaseService: Deleting user's splits from Firestore")
            let splitsQuery = try await db.collection("splits")
                .whereField("userId", isEqualTo: currentUser.id)
                .getDocuments()
            
            for document in splitsQuery.documents {
                try await document.reference.delete()
            }
            print("✅ FirebaseService: User's splits deleted from Firestore")
            
            // 3. Delete user's username reservation
            if !currentUser.username.isEmpty {
                print("🔥 FirebaseService: Releasing username reservation")
                try await db.collection("usernames").document(currentUser.username.lowercased()).delete()
                print("✅ FirebaseService: Username reservation released")
            }
            
            // 4. Delete user document from Firestore
            print("🔥 FirebaseService: Deleting user document from Firestore")
            try await db.collection("users").document(currentUser.id).delete()
            print("✅ FirebaseService: User document deleted from Firestore")
            
            // 5. Delete Firebase Auth account
            print("🔥 FirebaseService: Deleting Firebase Auth account")
            try await auth.currentUser?.delete()
            print("✅ FirebaseService: Firebase Auth account deleted")
            
            // 6. Clear local state
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
                self.isLoading = false
                self.authState = .signedOut
                print("✅ FirebaseService: Local state cleared, account deletion complete")
            }
            
            return true
            
        } catch {
            print("❌ FirebaseService: Account deletion failed - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                self.isLoading = false
            }
            return false
        }
    }
    
    // Helper method to check if an email is truly available (for debugging)
    func debugEmailAvailability(_ email: String) async {
        print("🔍 Debug: Checking email availability for \(email)")
        
        // Check Firestore
        do {
            let emailQuery = try await db.collection("users")
                .whereField("email", isEqualTo: email.lowercased())
                .limit(to: 1)
                .getDocuments()
            print("🔍 Firestore check: \(emailQuery.documents.isEmpty ? "Available" : "Taken")")
            
            if !emailQuery.documents.isEmpty {
                let document = emailQuery.documents.first!
                print("🔍 Found user document in Firestore with ID: \(document.documentID)")
                print("🔍 Document data: \(document.data())")
            }
        } catch {
            print("🔍 Firestore check: Error - \(error.localizedDescription)")
        }
        
        // Overall result
        let overallAvailable = await checkEmailAvailability(email)
        print("🔍 Overall result: \(overallAvailable ? "Available" : "Taken")")
        print("🔍 Note: Firebase Auth check is handled during actual signup attempt to avoid deprecated methods")
    }
    
    // Helper method to manually clean up orphaned user documents (for debugging)
    func cleanupOrphanedUser(_ email: String) async -> Bool {
        print("🧹 Debug: Attempting to clean up orphaned user document for \(email)")
        
        do {
            // Find ALL user documents by email (not just the first one)
            let emailQuery = try await db.collection("users")
                .whereField("email", isEqualTo: email.lowercased())
                .getDocuments()
            
            if emailQuery.documents.isEmpty {
                print("🧹 No user documents found for \(email)")
                return true
            }
            
            print("🧹 Found \(emailQuery.documents.count) user document(s) for \(email)")
            
            var totalCleaned = 0
            
            // Clean up each document found
            for document in emailQuery.documents {
                let userId = document.documentID
                print("🧹 Cleaning up user document with ID: \(userId)")
                
                // Delete the user document
                try await document.reference.delete()
                print("✅ User document \(userId) deleted successfully")
                
                // Also try to delete any associated data
                // Delete username reservation if exists
                let userData = document.data()
                if let username = userData["username"] as? String, !username.isEmpty {
                    try? await db.collection("usernames").document(username.lowercased()).delete()
                    print("✅ Username reservation cleaned up for \(userId)")
                }
                
                // Delete any splits associated with this user
                let splitsQuery = try await db.collection("splits")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                
                for splitDoc in splitsQuery.documents {
                    try await splitDoc.reference.delete()
                }
                print("✅ User splits cleaned up for \(userId) (\(splitsQuery.documents.count) documents)")
                
                totalCleaned += 1
            }
            
            print("✅ Total orphaned user documents cleaned up: \(totalCleaned)")
            return true
            
        } catch {
            print("❌ Failed to clean up orphaned user: \(error.localizedDescription)")
            return false
        }
    }
    
    // Method to force check email availability with retry logic
    func checkEmailAvailabilityWithRetry(_ email: String, maxRetries: Int = 3) async -> Bool {
        for attempt in 1...maxRetries {
            print("🔄 Email availability check attempt \(attempt)/\(maxRetries) for \(email)")
            
            let isAvailable = await checkEmailAvailability(email)
            
            if isAvailable {
                print("✅ Email is available on attempt \(attempt)")
                return true
            }
            
            if attempt < maxRetries {
                print("⏳ Email not available, waiting 2 seconds before retry...")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
        }
        
        print("❌ Email not available after \(maxRetries) attempts")
        return false
    }
    
    // MARK: - Apple Sign In
    
    /*
    func signInWithApple() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authResult = try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                let controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = AppleSignInDelegate { result in
                    continuation.resume(with: result)
                }
                controller.delegate = delegate
                controller.presentationContextProvider = delegate
                controller.performRequests()
                
                // Store delegate to prevent deallocation
                objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                }
            }
            
            // Handle Apple Sign In result
            if let appleIDCredential = authResult.credential as? ASAuthorizationAppleIDCredential {
                try await handleAppleSignIn(credential: appleIDCredential)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let appleIDToken = credential.identityToken,
              let _ = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID token"])
        }
        
        // For now, let's create a simple user profile without Firebase OAuth
        // This will be replaced with proper Firebase integration once we have the correct API
        let name = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let user = User(
            id: UUID().uuidString,
            email: credential.email ?? "",
            name: name.isEmpty ? "Apple User" : name,
            username: "", // Will be set during setup
            createdAt: Date()
        )
        
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
        }
        
        // Save user to Firestore
        try await saveUserToFirestore(user)
    }
    
    // MARK: - Helper Methods for Apple Sign In
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    */
    
    // MARK: - Google Sign In
    
    func cancelIncompleteSignup() async {
        guard let userId = auth.currentUser?.uid else { return }
        
        do {
            // Delete the incomplete user profile from Firestore
            try await db.collection("users").document(userId).delete()
            
            // Sign out from Firebase Auth
            try auth.signOut()
            
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
                self.authState = .signedOut
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to cancel signup: \(error.localizedDescription)"
            }
        }
    }
    
    func completeUsernameSetup(username: String) async {
        guard let userId = auth.currentUser?.uid else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Check if username is available
            let isAvailable = await checkUsernameAvailability(username)
            guard isAvailable else {
                DispatchQueue.main.async {
                    self.errorMessage = "Username is already taken"
                    self.isLoading = false
                }
                return
            }
            
            // Reserve the username
            try await reserveUsername(username: username.lowercased(), userId: userId)
            
            // Update user profile with username
            try await db.collection("users").document(userId).updateData([
                "username": username.lowercased(),
                "usernameLastChanged": Timestamp(date: Date())
            ])
            
            // Update current user object
            DispatchQueue.main.async {
                self.currentUser?.username = username.lowercased()
                self.currentUser?.usernameLastChanged = Date()
                // User is now fully authenticated with username
                self.isAuthenticated = true
                self.authState = .signedIn
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to set username: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signInWithGoogle() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(domain: "FirebaseService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured"])
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // Get UI elements on main thread
            let rootViewController = await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                    return nil as UIViewController?
                }
                return rootViewController
            }
            
            guard let rootViewController = rootViewController else {
                throw NSError(domain: "FirebaseService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No root view controller available"])
            }
            
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = signInResult.user.idToken?.tokenString else {
                throw NSError(domain: "FirebaseService", code: 4, userInfo: [NSLocalizedDescriptionKey: "No Google ID token available"])
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            )
            
            let authResult = try await auth.signIn(with: credential)
            
            // Check if this is a new user
            let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
            
            if isNewUser {
                // Create user profile for new users without username
                let user = User(
                    id: authResult.user.uid,
                    email: signInResult.user.profile?.email ?? "",
                    name: signInResult.user.profile?.name ?? "Google User",
                    username: "", // Empty username indicates needs setup
                    createdAt: Date()
                )
                
                try await saveUserToFirestore(user)
                
                DispatchQueue.main.async {
                    self.currentUser = user
                    // User is not fully authenticated until username is set
                    self.isAuthenticated = false
                    self.isLoading = false
                    // Set state to needs username setup
                    self.authState = .needsUsernameSetup
                }
            } else {
                // Existing user - load their profile
                handleUserSignIn(authResult.user)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Google Sign In failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Data Sync Methods
    
    func saveSplits(_ splits: [Split]) async {
        guard let userId = auth.currentUser?.uid else { return }
        
        do {
            let splitsRef = db.collection("users").document(userId).collection("splits")
            
            // Delete existing splits
            let existingSplits = try await splitsRef.getDocuments()
            for document in existingSplits.documents {
                try await document.reference.delete()
            }
            
            // Save new splits
            for split in splits {
                // Compress receipt image if it exists
                var compressedImageData: Data?
                if let receiptImageData = split.receiptImageData {
                    // Convert Data back to UIImage for compression
                    if let receiptImage = UIImage(data: receiptImageData) {
                        compressedImageData = compressImage(receiptImage, maxSize: 500 * 1024) // 500KB limit
                    }
                }
                
                // Only store image data if it's under the limit
                let imageDataString = compressedImageData?.base64EncodedString() ?? ""
                
                try await splitsRef.document(split.id.uuidString).setData([
                    "id": split.id.uuidString,
                    "description": split.description ?? "",
                    "date": split.date,
                    "totalAmount": split.totalAmount,
                    "userShares": split.userShares,
                    "detailedBreakdown": split.detailedBreakdown.mapValues { items in
                        items.map { [
                            "item": $0.item,
                            "cost": $0.cost
                        ] }
                    },
                    "receiptImageData": imageDataString,
                    "originalCurrency": split.originalCurrency
                ])
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to sync splits: \(error.localizedDescription)"
            }
        }
    }
    
    private func compressImage(_ image: UIImage, maxSize: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        // Reduce quality until image is under maxSize
        while let data = imageData, data.count > maxSize && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    func loadSplits() async -> [Split] {
        guard let userId = auth.currentUser?.uid else { return [] }
        
        do {
            let splitsRef = db.collection("users").document(userId).collection("splits")
            let snapshot = try await splitsRef.getDocuments()
            
            var splits: [Split] = []
            
            for document in snapshot.documents {
                let data = document.data()
                
                guard let idString = data["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let date = data["date"] as? Timestamp,
                      let totalAmount = data["totalAmount"] as? Double,
                      let userShares = data["userShares"] as? [String: Double],
                      let breakdownData = data["detailedBreakdown"] as? [String: [[String: Any]]] else {
                    continue
                }
                
                // Convert breakdown data
                var detailedBreakdown: [String: [ItemDetail]] = [:]
                for (user, items) in breakdownData {
                    detailedBreakdown[user] = items.compactMap { itemData in
                        guard let item = itemData["item"] as? String,
                              let cost = itemData["cost"] as? Double else { return nil }
                        return ItemDetail(item: item, cost: cost)
                    }
                }
                
                // Convert receipt image data
                var receiptImage: UIImage?
                if let imageDataString = data["receiptImageData"] as? String,
                   let imageData = Data(base64Encoded: imageDataString) {
                    receiptImage = UIImage(data: imageData)
                }
                
                let split = Split(
                    id: id,
                    description: data["description"] as? String,
                    date: date.dateValue(),
                    totalAmount: totalAmount,
                    userShares: userShares,
                    detailedBreakdown: detailedBreakdown,
                    receiptImage: receiptImage,
                    originalCurrency: data["originalCurrency"] as? String ?? "USD"
                )
                
                splits.append(split)
            }
            
            return splits.sorted { $0.date > $1.date }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load splits: \(error.localizedDescription)"
            }
            return []
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func handleUserSignIn(_ firebaseUser: FirebaseAuth.User) {
        Task {
            do {
                let userDoc = try await db.collection("users").document(firebaseUser.uid).getDocument()
                
                if let userData = userDoc.data() {
                    // User exists, load from Firestore
                    let user = User(
                        id: firebaseUser.uid,
                        email: userData["email"] as? String ?? "",
                        name: userData["name"] as? String ?? "",
                        username: userData["username"] as? String ?? "",
                        createdAt: (userData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        usernameLastChanged: (userData["usernameLastChanged"] as? Timestamp)?.dateValue(),
                        profilePictureURL: userData["profilePictureURL"] as? String,
                        assignedItemIDs: [], // Will be loaded separately if needed
                        preferredCurrency: userData["preferredCurrency"] as? String ?? "USD"
                    )
                    
                    DispatchQueue.main.async {
                        self.currentUser = user
                        
                        // Check if user's email is verified first
                        if !firebaseUser.isEmailVerified {
                            // User needs to verify email first
                            self.isAuthenticated = false
                            self.authState = .needsEmailVerification
                        } else if user.username.isEmpty {
                            // User is not fully authenticated until username is set
                            self.isAuthenticated = false
                            self.authState = .needsUsernameSetup
                        } else {
                            // User is fully authenticated with username
                            self.isAuthenticated = true
                            self.authState = .signedIn
                        }
                    }
                } else {
                    // User doesn't exist in Firestore - sign them out
                    DispatchQueue.main.async {
                        self.currentUser = nil
                        self.isAuthenticated = false
                        self.authState = .signedOut
                    }
                    // Sign out from Firebase Auth as well
                    try auth.signOut()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
                    self.isAuthenticated = false
                    self.authState = .signedOut
                }
            }
        }
    }
    
    private func handleUserSignOut() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
            self.authState = .signedOut
        }
    }
    
    private func saveUserToFirestore(_ user: User) async throws {
        var data: [String: Any] = [
            "email": user.email,
            "name": user.name,
            "username": user.username,
            "createdAt": Timestamp(date: user.createdAt)
        ]
        
        if let usernameLastChanged = user.usernameLastChanged {
            data["usernameLastChanged"] = Timestamp(date: usernameLastChanged)
        }
        
        if let profilePictureURL = user.profilePictureURL {
            data["profilePictureURL"] = profilePictureURL
        }
        
        try await db.collection("users").document(user.id).setData(data)
    }
    
    private func getErrorMessage(from error: Error) -> String {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .emailAlreadyInUse:
                return "An account with this email already exists"
            case .invalidEmail:
                return "Please enter a valid email address"
            case .weakPassword:
                return "Password is too weak. Please choose a stronger password"
            case .wrongPassword:
                return "Incorrect password. Please check your password and try again."
            case .userNotFound:
                return "No account found with this email address"
            case .tooManyRequests:
                return "Too many failed attempts. Please try again later"
            case .invalidCredential:
                return "Incorrect password. Please check your password and try again."
            default:
                return error.localizedDescription
            }
        }
        
        // Handle custom errors
        let nsError = error as NSError
            switch nsError.domain {
            case "FirebaseService":
            switch nsError.code {
            case 6:
                return "Username not found. Please check your username and try again."
            case 7:
                return "User profile not found. Please contact support."
            default:
                return nsError.localizedDescription
            }
            default:
                // Check for specific error codes that might indicate password issues
                if nsError.code == 17007 || nsError.code == 17020 {
                    return "Incorrect password. Please check your password and try again."
                }
                return error.localizedDescription
            }
        }
        
    // MARK: - Profile Picture Methods
    
    func uploadProfilePicture(_ image: UIImage) async {
        print("🔥 FirebaseService: Starting profile picture upload")
        
        guard let currentUser = self.currentUser else {
            print("❌ FirebaseService: No current user found")
            return
        }
        
        print("✅ FirebaseService: Current user found - \(currentUser.id)")
        print("✅ FirebaseService: User authenticated - \(auth.currentUser?.uid ?? "No Firebase Auth user")")
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Convert image to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("❌ FirebaseService: Failed to convert image to JPEG data")
                throw NSError(domain: "FirebaseService", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
            }
            
            print("✅ FirebaseService: Image converted to JPEG data - \(imageData.count) bytes")
            
            // Create storage reference
            let storageRef = storage.reference().child("profile_pictures/\(currentUser.id).jpg")
            print("✅ FirebaseService: Storage reference created - \(storageRef.fullPath)")
            
            // Upload image data
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            print("🔥 FirebaseService: Starting upload to Firebase Storage...")
            _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            print("✅ FirebaseService: Image uploaded successfully to Firebase Storage")
            
            // Get download URL with retry logic
            var downloadURL: URL?
            var retryCount = 0
            let maxRetries = 3
            
            while downloadURL == nil && retryCount < maxRetries {
                do {
                    downloadURL = try await storageRef.downloadURL()
                    print("✅ FirebaseService: Download URL obtained on attempt \(retryCount + 1) - \(downloadURL?.absoluteString ?? "nil")")
                } catch {
                    retryCount += 1
                    print("⚠️ FirebaseService: Failed to get download URL on attempt \(retryCount), error: \(error.localizedDescription)")
                    if retryCount < maxRetries {
                        // Wait before retrying
                        try await Task.sleep(nanoseconds: UInt64(500_000_000 * retryCount)) // 0.5s, 1s, 1.5s
                    }
                }
            }
            
            guard let finalDownloadURL = downloadURL else {
                throw NSError(domain: "FirebaseService", code: 9, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL after \(maxRetries) attempts"])
            }
            
            // Update user profile in Firestore
            print("🔥 FirebaseService: Updating Firestore user document...")
            try await db.collection("users").document(currentUser.id).updateData([
                "profilePictureURL": finalDownloadURL.absoluteString
            ])
            print("✅ FirebaseService: Firestore user document updated successfully")
            
            // Update local user object
            let updatedUser = User(
                id: currentUser.id,
                email: currentUser.email,
                name: currentUser.name,
                username: currentUser.username,
                createdAt: currentUser.createdAt,
                usernameLastChanged: currentUser.usernameLastChanged,
                profilePictureURL: finalDownloadURL.absoluteString,
                assignedItemIDs: currentUser.assignedItemIDs,
                preferredCurrency: currentUser.preferredCurrency
            )
            
            DispatchQueue.main.async {
                self.currentUser = updatedUser
                self.isLoading = false
                print("✅ FirebaseService: Local user object updated, upload complete")
            }
            
        } catch {
            print("❌ FirebaseService: Upload failed with error - \(error.localizedDescription)")
            print("❌ FirebaseService: Error details - \(error)")
            
            // Check if it's a Firebase Storage security rules error
            if let nsError = error as NSError? {
                print("❌ FirebaseService: Error domain - \(nsError.domain)")
                print("❌ FirebaseService: Error code - \(nsError.code)")
                print("❌ FirebaseService: Error user info - \(nsError.userInfo)")
            }
            
            DispatchQueue.main.async {
                self.errorMessage = "Failed to upload profile picture: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func removeProfilePicture() async {
        print("🔥 FirebaseService: Starting profile picture removal")
        
        guard let currentUser = self.currentUser else {
            print("❌ FirebaseService: No current user found")
            return
        }
        
        print("✅ FirebaseService: Current user found - \(currentUser.id)")
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Delete the image from Firebase Storage
            let storageRef = storage.reference().child("profile_pictures/\(currentUser.id).jpg")
            print("🔥 FirebaseService: Deleting from Firebase Storage - \(storageRef.fullPath)")
            
            try await storageRef.delete()
            print("✅ FirebaseService: Image deleted from Firebase Storage successfully")
            
            // Update user profile in Firestore to remove the URL
            print("🔥 FirebaseService: Updating Firestore user document...")
            try await db.collection("users").document(currentUser.id).updateData([
                "profilePictureURL": FieldValue.delete()
            ])
            print("✅ FirebaseService: Firestore user document updated successfully")
            
            // Update local user object
            let updatedUser = User(
                id: currentUser.id,
                email: currentUser.email,
                name: currentUser.name,
                username: currentUser.username,
                createdAt: currentUser.createdAt,
                usernameLastChanged: currentUser.usernameLastChanged,
                profilePictureURL: nil,
                assignedItemIDs: currentUser.assignedItemIDs,
                preferredCurrency: currentUser.preferredCurrency
            )
            
            DispatchQueue.main.async {
                self.currentUser = updatedUser
                self.isLoading = false
                print("✅ FirebaseService: Local user object updated, removal complete")
            }
            
        } catch {
            print("❌ FirebaseService: Removal failed with error - \(error.localizedDescription)")
            print("❌ FirebaseService: Error details - \(error)")
            
            DispatchQueue.main.async {
                self.errorMessage = "Failed to remove profile picture: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func updateUser(_ user: User) async throws {
        let userData: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "username": user.username,
            "createdAt": Timestamp(date: user.createdAt),
            "usernameLastChanged": user.usernameLastChanged != nil ? Timestamp(date: user.usernameLastChanged!) : NSNull(),
            "profilePictureURL": user.profilePictureURL as Any,
            "assignedItemIDs": user.assignedItemIDs.map { $0.uuidString },
            "preferredCurrency": user.preferredCurrency
        ]
        
        try await db.collection("users").document(user.id).setData(userData, merge: true)
        
        DispatchQueue.main.async {
            self.currentUser = user
        }
    }
}
