import SwiftUI

struct ItemAssignmentView: View {
    @State var items: [ReceiptItem] // Items to assign
    @State private var users: [User] = []
    @State private var selectedItems: [ReceiptItem] = []
    @State private var newUserName: String = ""
    @State private var errorMessage: String? = nil
    @State private var userShares: [String: Double] = [:]
    @State private var isResultViewActive = false
    @State private var detailedBreakdown: [String: [(item: String, cost: Double)]] = [:]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Add new user section
                HStack {
                    TextField("Enter new user name", text: $newUserName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        addUser()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2) // Slightly bigger than default
                            .foregroundColor(.blue)
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

                // Items & Users Section
                ScrollView {
                    VStack(spacing: 15) {
                        HStack(alignment: .top, spacing: 20) {
                            
                            // 🛍️ Items List
                            VStack {
                                Text("Items")
                                    .font(.headline)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 5)

                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 15)], spacing: 15) {
                                    ForEach(items, id: \.id) { item in
                                        let isSelected = selectedItems.contains(where: { $0.id == item.id })
                                        ItemRow(
                                            item: item,
                                            isSelected: isSelected,
                                            onTap: { toggleSelection(for: item) }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: 400, minHeight: 300)

                            // 👥 Users List
                            VStack {
                                Text("Users")
                                    .font(.headline)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 5)

                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 20)], spacing: 15) {
                                    ForEach(users.indices, id: \.self) { index in
                                        UserCard(
                                            user: users[index],
                                            items: items,
                                            onAssign: { assignSelectedItems(to: users[index]) },
                                            onUnassign: { item in unassignItem(item, from: users[index]) }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20) // Prevents last item from being cut off
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss the current view
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Assign Items")
                        .font(.headline)
                        .bold()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let (shares, breakdown) = calculateUserShares()
                        userShares = shares
                        detailedBreakdown = breakdown
                        isResultViewActive = true
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isNextButtonEnabled ? .blue : .gray) // Gray when disabled
                        .opacity(isNextButtonEnabled ? 1.0 : 0.5) // Reduce opacity when disabled
                    }
                    .disabled(!isNextButtonEnabled) // Disable button when no assignments
                }
            }

            // Hidden Navigation to Results View
            NavigationLink(
                destination: ResultView(userShares: userShares, detailedBreakdown: detailedBreakdown),
                isActive: $isResultViewActive
            ) {
                EmptyView()
            }
            .hidden()
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
}
