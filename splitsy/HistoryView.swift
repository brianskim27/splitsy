import SwiftUI

struct HistoryView: View {
    let pastReceipts = [
        Receipt(id: UUID(), storeName: "Joe's Coffee", date: "Jan 12, 2024"),
        Receipt(id: UUID(), storeName: "Whole Foods", date: "Jan 10, 2024")
    ]
    
    var body: some View {
        NavigationView {
            List(pastReceipts) { receipt in
                NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(receipt.storeName)
                                .font(.headline)
                            Text(receipt.date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
            .navigationTitle("History")
        }
    }
}

struct Receipt: Identifiable {
    let id: UUID
    let storeName: String
    let date: String
}
