import Foundation
import Combine
import UIKit

class SplitHistoryManager: ObservableObject {
    @Published var pastSplits: [Split] = [] {
        didSet {
            saveSplits()
        }
    }
    
    private let userDefaultsKey = "pastSplits"
    private var authManager: AuthenticationManager?
    
    init() {
        loadSplitsFromLocal()
        
        if pastSplits.isEmpty {
            print("No splits found.")
        }
    }
    
    func setAuthManager(_ authManager: AuthenticationManager) {
        self.authManager = authManager
        // Load splits from Firebase when auth manager is set
        Task {
            await loadSplitsFromFirebase()
        }
    }
    
    func addSplit(_ split: Split) {
        pastSplits.insert(split, at: 0)
    }
    
    private func saveSplits() {
        // Save to local storage
        if let encodedData = try? JSONEncoder().encode(pastSplits) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
        
        // Save to Firebase if authenticated
        if let authManager = authManager {
            authManager.saveSplits(pastSplits)
        }
    }
    
    private func loadSplitsFromLocal() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSplits = try? JSONDecoder().decode([Split].self, from: savedData) {
            pastSplits = decodedSplits
        }
    }
    
    private func loadSplitsFromFirebase() async {
        guard let authManager = authManager else { return }
        
        let firebaseSplits = await authManager.loadSplits()
        
        DispatchQueue.main.async {
            if !firebaseSplits.isEmpty {
                self.pastSplits = firebaseSplits
            }
        }
    }

}
