import Foundation

struct ReceiptItem: Identifiable {
    let id = UUID()
    var name: String
    var cost: Double
    var assignedUsers: [String] = [] // List of user names assigned to this item
}
