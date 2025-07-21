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
        
        // Add mock data if no splits are loaded
        if pastSplits.isEmpty {
            addMockData()
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
    
    private func addMockData() {
        let mockSplits = [
            Split(description: "Dinner with Friends", date: Date().addingTimeInterval(-86400 * 2), totalAmount: 124.50, userShares: ["Brian": 62.25, "Alex": 62.25], detailedBreakdown: ["Brian": [ItemDetail(item: "Pizza", cost: 45.0), ItemDetail(item: "Salad", cost: 17.25)], "Alex": [ItemDetail(item: "Burger", cost: 35.0), ItemDetail(item: "Fries", cost: 27.25)]], receiptImage: nil),
            Split(description: "Groceries", date: Date().addingTimeInterval(-86400 * 5), totalAmount: 78.20, userShares: ["Brian": 39.10, "Casey": 39.10], detailedBreakdown: ["Brian": [ItemDetail(item: "Milk", cost: 5.0), ItemDetail(item: "Bread", cost: 4.10)], "Casey": [ItemDetail(item: "Eggs", cost: 8.0), ItemDetail(item: "Cheese", cost: 22.0)]], receiptImage: nil),
            Split(description: "Coffee Run", date: Date().addingTimeInterval(-86400 * 10), totalAmount: 14.75, userShares: ["Brian": 7.38, "Dana": 7.37], detailedBreakdown: ["Brian": [ItemDetail(item: "Latte", cost: 7.38)], "Dana": [ItemDetail(item: "Cappuccino", cost: 7.37)]], receiptImage: nil),
        ]
        pastSplits = mockSplits
    }
}
