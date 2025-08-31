import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    var name: String
    var username: String
    let createdAt: Date
    var usernameLastChanged: Date?
    var profilePictureURL: String?
    var assignedItemIDs: [UUID] = [] // List of ReceiptItem IDs
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, username, createdAt, usernameLastChanged, profilePictureURL, assignedItemIDs
    }
    
    // Check if username can be changed (7 days since last change)
    var canChangeUsername: Bool {
        guard let lastChanged = usernameLastChanged else { return true }
        return Date().timeIntervalSince(lastChanged) >= 7 * 24 * 60 * 60 // 7 days in seconds
    }
    
    // Get days remaining until username can be changed again
    var daysUntilUsernameChange: Int {
        guard let lastChanged = usernameLastChanged else { return 0 }
        let timeRemaining = 7 * 24 * 60 * 60 - Date().timeIntervalSince(lastChanged)
        return max(0, Int(timeRemaining / (24 * 60 * 60)))
    }
}
