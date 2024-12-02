import SwiftUI

struct ReceiptHistoryView: View {
    var body: some View {
        List {
            Text("Receipt 1 - Example Restaurant")
            Text("Receipt 2 - Example Café")
        }
        .navigationTitle("Receipt History")
    }
}
