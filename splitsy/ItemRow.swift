import SwiftUI

struct ItemRow: View {
    let item: ReceiptItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(item.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(nil) // Allow multiple lines
                .fixedSize(horizontal: false, vertical: true) // Enable wrapping
                .frame(maxWidth: .infinity)

            Text("$\(item.cost, specifier: "%.2f")")
                .foregroundColor(.green)
                .font(.subheadline)
        }
        .padding()
        .frame(width: 160, height: 110)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}
