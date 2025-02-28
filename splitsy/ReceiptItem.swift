import Foundation

struct ReceiptItem: Identifiable {
    let id = UUID()
    let name: String
    let cost: Double
    var assignedUsers: [String] = [] // List of user names assigned to this item
}
