import SwiftUI

struct ItemAssignmentView: View {
    @Binding var items: [ReceiptItem] // Items to assign
    @Binding var users: [User] // Users and their assignments
    var onComplete: (([String: Double], [String: [ItemDetail]]) -> Void)? = nil
    @State private var selectedItems: [ReceiptItem] = []
    @State private var newUserName: String = ""
    @State private var errorMessage: String? = nil
    @State private var userShares: [String: Double] = [:]
    @State private var detailedBreakdown: [String: [ItemDetail]] = [:]

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                // Add new user section
                HStack(spacing: 12) {
                    TextField("Add person...", text: $newUserName)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .font(.body)
                        .autocapitalization(.words)
                    Button(action: { addUser() }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .bold()
                        .padding(.bottom, 5)
                }

                // Items Section
                VStack(alignment: .leading, spacing: 0) {
                                Text("Items")
                                    .font(.headline)
                                    .bold()
                        .padding(.leading, 8)
                        .padding(.top, 8)
                    ScrollView {
                        VStack(spacing: 10) {
                                    ForEach(items, id: \.id) { item in
                                        let isSelected = selectedItems.contains(where: { $0.id == item.id })
                                Button(action: { toggleSelection(for: item) }) {
                                    HStack {
                                        Text(item.name)
                                            .font(.body)
                                            .bold()
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("$\(item.cost, specifier: "%.2f")")
                                            .foregroundColor(.green)
                                            .font(.subheadline)
                                            .bold()
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                    }
                                }
                        .padding(.vertical, 4)
                            }
                    .frame(maxHeight: 320)
                }
                .background(Color(.systemBackground))
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity)

                // People Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("People")
                                    .font(.headline)
                                    .bold()
                        .padding(.leading, 8)
                        .padding(.top, 8)
                    if users.isEmpty {
                        Text("No people added yet")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.vertical, 32)
                                    .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                    ForEach(users.indices, id: \.self) { index in
                                    let user = users[index]
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.blue.opacity(0.7))
                                                .frame(width: 36, height: 36)
                                                .overlay(Text(userInitials(user.name)).foregroundColor(.white).font(.headline))
                                            Text(user.name)
                                                .font(.body)
                                                .bold()
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                            Spacer()
                                            Button(action: { removeUser(user) }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        if !user.assignedItemIDs.isEmpty {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 6) {
                                                    ForEach(user.assignedItemIDs, id: \.self) { itemId in
                                                        if let item = items.first(where: { $0.id == itemId }) {
                                                            Text(item.name)
                                                                .font(.caption)
                                                                .padding(.horizontal, 8)
                                                                .padding(.vertical, 4)
                                                                .background(Color.blue.opacity(0.15))
                                                                .foregroundColor(.blue)
                                                                .cornerRadius(8)
                                                                .onTapGesture {
                                                                    unassignItem(item, from: user)
                                                                }
                                                        }
                                                    }
                                                }
                                                .frame(height: 28)
                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                                    }
                                    .padding(.vertical, 8)
                        .padding(.horizontal)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if !selectedItems.isEmpty {
                                            assignSelectedItems(to: user)
                                        }
                                    }
                                }
                    }
                            .padding(.vertical, 4)
                        }
                        .frame(maxHeight: 320)
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, minHeight: 120)

                Spacer()

                // Next Button
                Button(action: {
                    let (shares, breakdown) = calculateUserShares()
                    userShares = shares
                    detailedBreakdown = breakdown
                    onComplete?(shares, breakdown)
                }) {
                    HStack {
                        Spacer()
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(isNextButtonEnabled ? Color.blue : Color.gray)
                    .cornerRadius(14)
                    .shadow(color: isNextButtonEnabled ? Color.blue.opacity(0.18) : .clear, radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .disabled(!isNextButtonEnabled)
                .opacity(isNextButtonEnabled ? 1.0 : 0.5)
            }
            .padding(.top, 12)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Assign")
                        .font(.title2)
                        .bold()
                }
            }
        }
    }
    
    private var isNextButtonEnabled: Bool {
        // Cache the result to avoid repeated computation
        return !users.isEmpty && users.contains { !$0.assignedItemIDs.isEmpty }
    }
    
    // Add user
    private func addUser() {
        let trimmedName = newUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }

        if users.contains(where: { $0.name == trimmedName }) {
            errorMessage = "User already exists"
            return
        }

        users.append(User(id: UUID().uuidString, email: "", name: trimmedName, createdAt: Date(), assignedItemIDs: []))
        newUserName = ""
        errorMessage = nil
    }

    // Remove user
    private func removeUser(_ user: User) {
        // First, unassign all items from this user
        for itemID in user.assignedItemIDs {
            if let item = items.first(where: { $0.id == itemID }) {
                unassignItem(item, from: user)
            }
        }
        
        // Then remove the user from the users array
        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            users.remove(at: userIndex)
        }
    }

    // Select/Deselect Items
    private func toggleSelection(for item: ReceiptItem) {
        if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }

    private func toggleSelectAll() {
        selectedItems = selectedItems.count == items.count ? [] : items
    }

    // Assign Selected Items to a User
    private func assignSelectedItems(to user: User) {
        guard !selectedItems.isEmpty else {
            return
        }

        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            for item in selectedItems {
                if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
                    if !items[itemIndex].assignedUsers.contains(user.name) {
                        items[itemIndex].assignedUsers.append(user.name)
                    }

                    if !users[userIndex].assignedItemIDs.contains(item.id) {
                        users[userIndex].assignedItemIDs.append(item.id)
                    }
                }
            }
            errorMessage = nil
        }
    }

    // Unassign an Item from a User
    private func unassignItem(_ item: ReceiptItem, from user: User) {
        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            if let itemIDIndex = users[userIndex].assignedItemIDs.firstIndex(of: item.id) {
                users[userIndex].assignedItemIDs.remove(at: itemIDIndex)
            }

            if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
                if let userIndexInItem = items[itemIndex].assignedUsers.firstIndex(of: user.name) {
                    items[itemIndex].assignedUsers.remove(at: userIndexInItem)
                }
            }
        }
    }

    // Calculate User Shares
    private func calculateUserShares() -> ([String: Double], [String: [ItemDetail]]) {
        var shares: [String: Double] = [:]
        var breakdown: [String: [ItemDetail]] = [:]

        for user in users {
            var userTotal: Double = 0
            var userItems: [ItemDetail] = []

            for itemID in user.assignedItemIDs {
                if let item = items.first(where: { $0.id == itemID }) {
                    let costPerUser = item.cost / Double(item.assignedUsers.count)
                    userTotal += costPerUser
                    userItems.append(ItemDetail(item: item.name, cost: costPerUser))
                    }
                }
            
            if userTotal > 0 {
                shares[user.name] = userTotal
                breakdown[user.name] = userItems
            }
        }
        
        return (shares, breakdown)
    }

    // Helper for initials
    private func userInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count == 1, let first = parts.first?.first {
            return String(first).uppercased()
        } else if let first = parts.first?.first, let last = parts.last?.first {
            return String(first).uppercased() + String(last).uppercased()
        } else {
            return "?"
        }
    }
}
