import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let name: String
    let createdAt: Date
    var assignedItemIDs: [UUID] = [] // List of ReceiptItem IDs
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, createdAt, assignedItemIDs
    }
}
