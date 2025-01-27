import SwiftUI

struct UserRow: View {
    let user: User
    let items: [ReceiptItem]
    let onAssign: () -> Void
    let onUnassign: (ReceiptItem) -> Void

    var body: some View {
        VStack {
            Button(action: onAssign) {
                Text(user.name)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading) {
                ForEach(user.assignedItemIDs, id: \.self) { itemID in
                    if let item = items.first(where: { $0.id == itemID }) {
                        HStack {
                            Text(item.name)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(5)
                                .onTapGesture {
                                    onUnassign(item)
                                }
                        }
                    }
                }
            }
            .padding(.top, 5)
        }
    }
}
