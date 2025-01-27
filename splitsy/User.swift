import Foundation

struct User: Identifiable {
    let id: String
    let name: String
    var assignedItemIDs: [UUID] = [] // List of ReceiptItem IDs
}
