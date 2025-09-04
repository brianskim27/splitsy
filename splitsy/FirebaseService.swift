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
            // Check if email is already taken
            let isEmailAvailable = await checkEmailAvailability(email)
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
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = false // Not fully authenticated until username is set
                self.authState = .needsUsernameSetup
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = self.getErrorMessage(from: error)
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
            // Check if email is already taken
            let isEmailAvailable = await checkEmailAvailability(email)
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
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = self.getErrorMessage(from: error)
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
            let emailQuery = try await db.collection("users")
                .whereField("email", isEqualTo: email.lowercased())
                .limit(to: 1)
                .getDocuments()
            return emailQuery.documents.isEmpty
        } catch {
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
                assignedItemIDs: currentUser.assignedItemIDs
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
        guard let user = auth.currentUser else { return }
        
        do {
            try await user.sendEmailVerification()
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to send verification email: \(error.localizedDescription)"
            }
        }
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
                    "receiptImageData": imageDataString
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
                    receiptImage: receiptImage
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
                        profilePictureURL: userData["profilePictureURL"] as? String
                    )
                    
                    DispatchQueue.main.async {
                        self.currentUser = user
                        // Check if user needs username setup
                        if user.username.isEmpty {
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
                return "Incorrect password"
            case .userNotFound:
                return "No account found with this email address"
            case .tooManyRequests:
                return "Too many failed attempts. Please try again later"
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
                assignedItemIDs: currentUser.assignedItemIDs
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
                assignedItemIDs: currentUser.assignedItemIDs
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
}
