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
        // Clean up any existing large UserDefaults data
        cleanupLargeUserDefaultsData()
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
        
        // Create a lightweight version for local storage (without large images)
        let lightweightSplits = pastSplits.map { split in
            var lightweightSplit = split
            lightweightSplit.receiptImageData = nil // Remove large image data for local storage
            return lightweightSplit
        }
        
        // Save lightweight version to local storage (user-specific)
        if let encodedData = try? JSONEncoder().encode(lightweightSplits) {
            // Check if data is reasonable size (under 1MB)
            if encodedData.count < 1024 * 1024 {
                UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
            } else {
                // If too large, just save a flag that we have data
                UserDefaults.standard.set(true, forKey: "\(userDefaultsKey)_hasData")
            }
        }
        
        // Save full data to Firebase
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
        
        // Try to load lightweight data first
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSplits = try? JSONDecoder().decode([Split].self, from: savedData) {
            pastSplits = decodedSplits
        } else if UserDefaults.standard.bool(forKey: "\(userDefaultsKey)_hasData") {
            // If we have a flag that data exists but can't load it, 
            // we'll rely on Firebase to load the data
            pastSplits = []
        }
    }
    
    func clearData() {
        pastSplits = []
        // Clear local storage for current user
        if let _ = authManager?.currentUser {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey)_hasData")
        }
    }
    
    private func cleanupLargeUserDefaultsData() {
        // Clean up any existing large UserDefaults data that might be causing issues
        let userDefaults = UserDefaults.standard
        let allKeys = userDefaults.dictionaryRepresentation().keys
        
        for key in allKeys {
            if key.hasPrefix("pastSplits_") {
                if let data = userDefaults.data(forKey: key) {
                    // If data is too large (>1MB), remove it
                    if data.count > 1024 * 1024 {
                        userDefaults.removeObject(forKey: key)
                        print("Removed large UserDefaults data for key: \(key)")
                    }
                }
            }
        }
        
        // Also clean up any old fun facts data that might be large
        if let data = userDefaults.data(forKey: "funFacts_lastFactIndex") {
            if data.count > 1024 * 1024 {
                userDefaults.removeObject(forKey: "funFacts_lastFactIndex")
                print("Removed large fun facts UserDefaults data")
            }
        }
    }

}
