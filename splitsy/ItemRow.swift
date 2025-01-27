import SwiftUI

struct ItemRow: View {
    let item: ReceiptItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(item.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("$\(item.cost, specifier: "%.2f")")
                .foregroundColor(.green)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.secondary.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
    }
}
