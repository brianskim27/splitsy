import Foundation
import UIKit

struct ItemDetail: Codable, Hashable {
    let item: String
    let cost: Double
}

struct Split: Identifiable, Codable, Equatable {
    let id: UUID
    var description: String?
    let date: Date
    let totalAmount: Double
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    var receiptImageData: Data?
    let originalCurrency: String // Currency when the split was created
    
    enum CodingKeys: String, CodingKey {
        case id, description, date, totalAmount, userShares, detailedBreakdown, receiptImageData, originalCurrency
    }
    
    init(id: UUID = UUID(), description: String? = nil, date: Date = Date(), totalAmount: Double, userShares: [String: Double], detailedBreakdown: [String: [ItemDetail]], receiptImage: UIImage? = nil, originalCurrency: String = "USD") {
        self.id = id
        self.description = description
        self.date = date
        self.totalAmount = totalAmount
        self.userShares = userShares
        self.detailedBreakdown = detailedBreakdown
        self.receiptImageData = receiptImage?.jpegData(compressionQuality: 0.8)
        self.originalCurrency = originalCurrency
    }
}
