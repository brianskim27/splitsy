import SwiftUI

struct ItemAssignmentView: View {
    @State var items: [ReceiptItem] // Items to assign
    @State private var users: [User] = []
    @State private var selectedItems: [ReceiptItem] = [] // Track selected items
    @State private var newUserName: String = ""
    @State private var errorMessage: String? = nil
    @State private var userShares: [String: Double] = [:] // Stores calculated shares
    @State private var isResultViewActive = false // Controls navigation to ResultView
    @State private var detailedBreakdown: [String: [(item: String, cost: Double)]] = [:]

    var body: some View {
        NavigationStack {
            VStack {
                // Add new user section
                HStack {
                    TextField("Enter new user name", text: $newUserName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add User") {
                        addUser()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom)
                }

                // Main assignment view
                HStack {
                    // Items list
                    VStack {
                        HStack {
                            Text("Items")
                                .font(.headline)
                            Spacer()
                            Button(action: toggleSelectAll) {
                                Text(selectedItems.count == items.count ? "Deselect All" : "Select All")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        List {
                            ForEach(items, id: \.id) { item in
                                let isSelected = selectedItems.contains(where: { $0.id == item.id })
                                ItemRow(
                                    item: item,
                                    isSelected: isSelected,
                                    onTap: { toggleSelection(for: item) }
                                )
                            }
                        }
                        .frame(maxWidth: 200)
                    }

                    // Users list
                    VStack {
                        Text("Users")
                            .font(.headline)
                            .padding(.bottom)

                        ScrollView {
                            ForEach(users.indices, id: \.self) { index in
                                UserRow(
                                    user: users[index],
                                    items: items,
                                    onAssign: { assignSelectedItems(to: users[index]) },
                                    onUnassign: { item in unassignItem(item, from: users[index]) }
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // NavigationLink to ResultView
                NavigationLink(
                    destination: ResultView(userShares: userShares, detailedBreakdown: detailedBreakdown),
                    isActive: $isResultViewActive
                ) {
                    EmptyView()
                }
                .hidden()

                // Calculate and navigate
                Button("Calculate Shares") {
                    let (shares, breakdown) = calculateUserShares()
                    userShares = shares
                    detailedBreakdown = breakdown
                    isResultViewActive = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .navigationTitle("Assign Items")
            .padding()
        }
    }

    // Add a new user
    private func addUser() {
        guard !newUserName.isEmpty else {
            errorMessage = "User name cannot be empty."
            return
        }

        guard !users.contains(where: { $0.name == newUserName }) else {
            errorMessage = "User with the same name already exists."
            return
        }

        users.append(User(id: UUID().uuidString, name: newUserName, assignedItemIDs: []))
        newUserName = ""
        errorMessage = nil
    }

    private func toggleSelection(for item: ReceiptItem) {
        if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }

    private func toggleSelectAll() {
        if selectedItems.count == items.count {
            selectedItems.removeAll()
        } else {
            selectedItems = items
        }
    }

    private func assignSelectedItems(to user: User) {
        guard !selectedItems.isEmpty else {
            errorMessage = "No items selected."
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

    private func calculateUserShares() -> (shares: [String: Double], breakdown: [String: [(item: String, cost: Double)]]) {
        var userShares: [String: Double] = [:]
        var detailedBreakdown: [String: [(item: String, cost: Double)]] = [:]

        for user in users {
            var totalCost = 0.0
            var userBreakdown: [(item: String, cost: Double)] = []

            for itemID in user.assignedItemIDs {
                if let item = items.first(where: { $0.id == itemID }) {
                    if item.assignedUsers.count > 0 {
                        // Calculate split cost
                        let splitCost = round((item.cost / Double(item.assignedUsers.count)) * 100) / 100
                        totalCost += splitCost

                        // Add item to user’s detailed breakdown
                        userBreakdown.append((item: item.name, cost: splitCost))
                    }
                }
            }

            // Store user’s total cost and detailed breakdown
            userShares[user.name] = round(totalCost * 100) / 100
            detailedBreakdown[user.name] = userBreakdown
        }

        return (userShares, detailedBreakdown)
    }
}
