import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink("Scan New Receipt", destination: ReceiptScannerView())
                NavigationLink("View Receipt History", destination: ReceiptHistoryView())
            }
            .navigationTitle("Receipt Scanner")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
