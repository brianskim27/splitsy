import Foundation

struct ReceiptItem: Identifiable {
    let id = UUID()
    let name: String
    let cost: Double
}
