import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(receipt.storeName)
                .font(.title2)
                .bold()

            Text(receipt.date)
                .foregroundColor(.gray)

            Divider()

            Text("Final Breakdown:")
                .font(.headline)
            
            // Dummy breakdown, replace with real data
            List {
                Text("Item 1 - $4.50")
                Text("Item 2 - $6.99")
                Text("Item 3 - $2.99")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Receipt Details")
    }
}
