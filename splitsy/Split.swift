import Foundation
import UIKit

struct ItemDetail: Codable, Hashable {
    let item: String
    let cost: Double
}

struct Split: Identifiable, Codable {
    let id: UUID
    var description: String?
    let date: Date
    let totalAmount: Double
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    var receiptImageData: Data?
    
    enum CodingKeys: String, CodingKey {
        case id, description, date, totalAmount, userShares, detailedBreakdown, receiptImageData
    }
    
    init(id: UUID = UUID(), description: String? = nil, date: Date = Date(), totalAmount: Double, userShares: [String: Double], detailedBreakdown: [String: [ItemDetail]], receiptImage: UIImage? = nil) {
        self.id = id
        self.description = description
        self.date = date
        self.totalAmount = totalAmount
        self.userShares = userShares
        self.detailedBreakdown = detailedBreakdown
        self.receiptImageData = receiptImage?.jpegData(compressionQuality: 0.8)
    }
}
