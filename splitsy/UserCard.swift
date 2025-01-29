import SwiftUI

struct UserCard: View {
    let user: User
    let items: [ReceiptItem]
    let onAssign: () -> Void
    let onUnassign: (ReceiptItem) -> Void

    var body: some View {
        VStack(spacing: 10) {
            
            // User Name Button with Gradient
            Button(action: onAssign) {
                Text(user.name)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
            }
            
            // Assigned Items in Rounded Pills
            VStack(spacing: 5) {
                VStack {
                    ForEach(user.assignedItemIDs, id: \.self) { itemID in
                        if let item = items.first(where: { $0.id == itemID }) {
                            Text(item.name)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .frame(minWidth: 120) // Ensures consistent width
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .onTapGesture {
                                    onUnassign(item)
                                }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 3)
        }
        .padding(.horizontal)
    }
}
