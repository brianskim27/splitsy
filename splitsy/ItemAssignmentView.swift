import SwiftUI

struct ItemAssignmentView: View {
    @Binding var items: [ReceiptItem] // Items to assign
    @Binding var users: [User] // Users and their assignments
    var onComplete: (([String: Double], [String: [(item: String, cost: Double)]]) -> Void)? = nil
    @State private var selectedItems: [ReceiptItem] = []
    @State private var newUserName: String = ""
    @State private var errorMessage: String? = nil
    @State private var userShares: [String: Double] = [:]
    @State private var detailedBreakdown: [String: [(item: String, cost: Double)]] = [:]

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

                // People Section (vertical, full width)
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
                                    Button(action: { assignSelectedItems(to: user) }) {
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.blue.opacity(0.7))
                                                .frame(width: 36, height: 36)
                                                .overlay(Text(userInitials(user.name)).foregroundColor(.white).font(.headline))
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(user.name)
                                                    .font(.body)
                                                    .bold()
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
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
                                                                }
                                                            }
                                                        }
                                                        .frame(height: 28)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(selectedItems.isEmpty)
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

                // Modern Next Button
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
                    Text("Assign Items")
                        .font(.headline)
                        .bold()
                }
            }
        }
    }
    
    private var isNextButtonEnabled: Bool {
        return users.contains { !$0.assignedItemIDs.isEmpty }
    }
    
    // Add User Logic
    private func addUser() {
        guard !newUserName.isEmpty else {
            return
        }

        guard !users.contains(where: { $0.name == newUserName }) else {
            return
        }

        users.append(User(id: UUID().uuidString, name: newUserName, assignedItemIDs: []))
        newUserName = ""
        errorMessage = nil
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
    private func calculateUserShares() -> (shares: [String: Double], breakdown: [String: [(item: String, cost: Double)]]) {
        var userShares: [String: Double] = [:]
        var detailedBreakdown: [String: [(item: String, cost: Double)]] = [:]

        for user in users {
            var totalCost = 0.0
            var userBreakdown: [(item: String, cost: Double)] = []

            for itemID in user.assignedItemIDs {
                if let item = items.first(where: { $0.id == itemID }) {
                    if item.assignedUsers.count > 0 {
                        let splitCost = round((item.cost / Double(item.assignedUsers.count)) * 100) / 100
                        totalCost += splitCost
                        userBreakdown.append((item: item.name, cost: splitCost))
                    }
                }
            }

            userShares[user.name] = round(totalCost * 100) / 100
            detailedBreakdown[user.name] = userBreakdown
        }

        return (userShares, detailedBreakdown)
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
