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
    
    init() {
        loadSplits()
        
        if pastSplits.isEmpty {
            print("No splits found.")
        }
    }
    
    func addSplit(_ split: Split) {
        pastSplits.insert(split, at: 0)
    }
    
    private func saveSplits() {
        if let encodedData = try? JSONEncoder().encode(pastSplits) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func loadSplits() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSplits = try? JSONDecoder().decode([Split].self, from: savedData) {
            pastSplits = decodedSplits
        }
    }

}
