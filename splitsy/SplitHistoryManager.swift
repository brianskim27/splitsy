import Foundation
import Combine
import UIKit

class SplitHistoryManager: ObservableObject {
    @Published var pastSplits: [Split] = [] {
        didSet {
            saveSplits()
        }
    }
    
    private var userDefaultsKey: String {
        guard let userId = authManager?.currentUser?.id else { return "pastSplits" }
        return "pastSplits_\(userId)"
    }
    
    private var authManager: AuthenticationManager?
    
    init() {
        // Don't load from local storage initially - wait for user authentication
    }
    
    func setAuthManager(_ authManager: AuthenticationManager) {
        let currentUserId = self.authManager?.currentUser?.id
        let newUserId = authManager.currentUser?.id
        
        // Check if we're switching to a different user
        let isDifferentUser = currentUserId != newUserId
        
        // Only clear data if switching to a different user
        if isDifferentUser {
            clearData()
        }
        
        self.authManager = authManager
        // Load splits from Firebase for the authenticated user
        Task {
            await loadSplitsFromFirebase()
        }
    }
    
    func addSplit(_ split: Split) {
        pastSplits.insert(split, at: 0)
    }
    
    private func saveSplits() {
        // Only save to local storage if we have an authenticated user
        guard let _ = authManager?.currentUser else { return }
        
        // Save to local storage (user-specific)
        if let encodedData = try? JSONEncoder().encode(pastSplits) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
        
        // Save to Firebase
        if let authManager = authManager {
            authManager.saveSplits(pastSplits)
        }
    }
    
    private func loadSplitsFromFirebase() async {
        guard let authManager = authManager else { return }
        
        let firebaseSplits = await authManager.loadSplits()
        
        DispatchQueue.main.async {
            if !firebaseSplits.isEmpty {
                self.pastSplits = firebaseSplits
            } else {
                // If no Firebase data, try to load from local storage for this user
                self.loadSplitsFromLocal()
            }
        }
    }
    
    private func loadSplitsFromLocal() {
        guard let _ = authManager?.currentUser else { return }
        
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSplits = try? JSONDecoder().decode([Split].self, from: savedData) {
            pastSplits = decodedSplits
        }
    }
    
    func clearData() {
        pastSplits = []
        // Clear local storage for current user
        if let _ = authManager?.currentUser {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }

}
