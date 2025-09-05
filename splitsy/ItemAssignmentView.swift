import SwiftUI

struct ItemAssignmentView: View {
    @Binding var items: [ReceiptItem] // Items to assign
    @Binding var users: [User] // Users and their assignments
    var onComplete: (([String: Double], [String: [ItemDetail]]) -> Void)? = nil
    @EnvironmentObject var currencyManager: CurrencyManager
    @State private var newUserName: String = ""
    @State private var errorMessage: String? = nil
    @State private var userShares: [String: Double] = [:]
    @State private var detailedBreakdown: [String: [ItemDetail]] = [:]
    @State private var tipAmount: String = ""
    @State private var isTipEnabled: Bool = false
    @State private var editingUser: User? = nil
    @State private var editingUserName: String = ""
    @FocusState private var isTipFieldFocused: Bool
    @FocusState private var isEditingNameFocused: Bool
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Add new user section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Person")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            TextField("Person name", text: $newUserName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .font(.body)
                                .autocapitalization(.words)
                            
                            Button(action: { addUser() }) {
                                Text("Add")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                    }

                    // People Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("People")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if users.isEmpty {
                            Text("No people added yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(users.indices, id: \.self) { index in
                                    let user = users[index]
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            if editingUser?.id == user.id {
                                                TextField("Name", text: $editingUserName)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .textFieldStyle(PlainTextFieldStyle())
                                                    .focused($isEditingNameFocused)
                                                    .onSubmit {
                                                        saveUserName()
                                                    }
                                            } else {
                                                Text(user.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                if editingUser?.id == user.id {
                                                    Button(action: saveUserName) {
                                                        Image(systemName: "checkmark")
                                                            .font(.caption)
                                                            .foregroundColor(.green)
                                                    }
                                                    Button(action: cancelEditing) {
                                                        Image(systemName: "xmark")
                                                            .font(.caption)
                                                            .foregroundColor(.red)
                                                    }
                                                } else {
                                                    Button(action: { startEditingUser(user) }) {
                                                        Image(systemName: "pencil")
                                                            .font(.caption)
                                                            .foregroundColor(.blue)
                                                    }
                                                    Button(action: { removeUser(user) }) {
                                                        Image(systemName: "trash")
                                                            .font(.caption)
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if let assignedItems = assignedItemsPerPerson[index], !assignedItems.isEmpty {
                                            VStack(alignment: .leading, spacing: 4) {
                                                ForEach(assignedItems, id: \.id) { item in
                                                    HStack {
                                                        Text(item.name)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                        Spacer()
                                                        Text("$\(item.cost / Double(item.assignedUsers.count), specifier: "%.2f")")
                                                            .font(.caption)
                                                            .foregroundColor(.green)
                                                        
                                                        Button(action: {
                                                            removeItemFromUser(itemId: item.id, userId: user.id)
                                                        }) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.system(size: 12))
                                                                .foregroundColor(.red)
                                                        }
                                                        .accessibilityLabel("Remove \(item.name) from \(user.name)")
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("No items assigned")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .italic()
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                            }
                        }
                    }

                    // Items Section - Modern Wheel Design
                    if !items.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header
                            HStack {
                                Text("Items to Assign")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 0)
                            .padding(.bottom, 16)
                            
                            // Horizontal Scrollable Items Wheel
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(items) { item in
                                        ItemAssignmentCard(
                                            item: item,
                                            users: $users,
                                            items: $items,
                                            onAssignmentChange: { }
                                        )
                                    }
                                }
                                .padding(.horizontal, 0)
                            }
                        }
                        .padding(.bottom, 20)
                    }

                    // Tip Section
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Add Tip", isOn: $isTipEnabled)
                            .font(.headline)
                        
                        if isTipEnabled {
                            VStack(alignment: .leading, spacing: 16) {
                                // Tip amount input
                                HStack {
                                    Text(currencyManager.selectedCurrency.symbol)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.00", text: $tipAmount)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .focused($isTipFieldFocused)
                                    
                                    if isTipFieldFocused {
                                        Button("Done") {
                                            isTipFieldFocused = false
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                
                                HStack {
                                    Text("Tip Percentage:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(String(format: "%.1f", tipPercentage))%")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Tip will be split evenly among all people")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }

                    // Total Summary
                    if !items.isEmpty && !users.isEmpty {
                        VStack(spacing: 12) {
                            Divider()
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Assigned Subtotal:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(assignedSubtotal, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                
                                if isTipEnabled && tipAmountDouble > 0 {
                                    HStack {
                                        Text("Tip:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("$\(tipAmountDouble, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Total:")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("$\(assignedSubtotal + tipAmountDouble, specifier: "%.2f")")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .padding(.bottom, keyboardHeight)
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Assign")
                    .font(.title2)
                    .bold()
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next") {
                    let (shares, breakdown) = calculateUserShares()
                    userShares = shares
                    detailedBreakdown = breakdown
                    onComplete?(shares, breakdown)
                }
                .disabled(!isNextButtonEnabled)
                .opacity(isNextButtonEnabled ? 1 : 0.6)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping anywhere
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }
    
    private var subtotal: Double {
        items.reduce(0) { $0 + $1.cost }
    }
    
    private var assignedItemsPerPerson: [Int: [ReceiptItem]] {
        var assignments: [Int: [ReceiptItem]] = [:]
        
        // Initialize all people with empty arrays
        for i in 0..<users.count {
            assignments[i] = []
        }
        
        // Add assigned items
        for (index, user) in users.enumerated() {
            for itemID in user.assignedItemIDs {
                if let item = items.first(where: { $0.id == itemID }) {
                    assignments[index]?.append(item)
                }
            }
        }
        
        return assignments
    }
    
    private var assignedSubtotal: Double {
        var total = 0.0
        for user in users {
            for itemID in user.assignedItemIDs {
                if let item = items.first(where: { $0.id == itemID }) {
                    let costPerUser = item.cost / Double(item.assignedUsers.count)
                    total += costPerUser
                }
            }
        }
        return total
    }
    
    private var tipAmountDouble: Double {
        guard let amount = Double(tipAmount) else { return 0 }
        return amount
    }
    
    private var tipPercentage: Double {
        guard assignedSubtotal > 0 else { return 0 }
        return (tipAmountDouble / assignedSubtotal) * 100
    }
    
    private var isNextButtonEnabled: Bool {
        // Cache the result to avoid repeated computation
        return !users.isEmpty && users.contains { !$0.assignedItemIDs.isEmpty }
    }
    
    // User editing functions
    private func startEditingUser(_ user: User) {
        editingUser = user
        editingUserName = user.name
        isEditingNameFocused = true
    }
    
    private func saveUserName() {
        let trimmedName = editingUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            cancelEditing()
            return
        }
        
        if let userIndex = users.firstIndex(where: { $0.id == editingUser?.id }) {
            // Update user name
            users[userIndex].name = trimmedName
            
            // Update assigned users in items
            for itemIndex in items.indices {
                if let userIndexInItem = items[itemIndex].assignedUsers.firstIndex(of: editingUser?.name ?? "") {
                    items[itemIndex].assignedUsers[userIndexInItem] = trimmedName
                }
            }
        }
        
        editingUser = nil
        editingUserName = ""
        isEditingNameFocused = false
    }
    
    private func cancelEditing() {
        editingUser = nil
        editingUserName = ""
        isEditingNameFocused = false
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

        users.append(User(id: UUID().uuidString, email: "", name: trimmedName, username: "", createdAt: Date(), assignedItemIDs: []))
        newUserName = ""
        errorMessage = nil
    }

    // Remove user
    private func removeUser(_ user: User) {
        // First, unassign all items from this user
        for itemID in user.assignedItemIDs {
            if let itemIndex = items.firstIndex(where: { $0.id == itemID }) {
                if let userIndexInItem = items[itemIndex].assignedUsers.firstIndex(of: user.name) {
                    items[itemIndex].assignedUsers.remove(at: userIndexInItem)
                }
            }
        }
        
        // Then remove the user from the users array
        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            users.remove(at: userIndex)
        }
    }
    
    // Remove specific item from specific user
    private func removeItemFromUser(itemId: UUID, userId: String) {
        // Find the user and item
        guard let userIndex = users.firstIndex(where: { $0.id == userId }),
              let itemIndex = items.firstIndex(where: { $0.id == itemId }) else { return }
        
        let user = users[userIndex]
        
        // Remove the user from the item's assigned users
        if let userIndexInItem = items[itemIndex].assignedUsers.firstIndex(of: user.name) {
            items[itemIndex].assignedUsers.remove(at: userIndexInItem)
        }
        
        // Remove the item from the user's assigned items
        if let itemIndexInUser = users[userIndex].assignedItemIDs.firstIndex(of: itemId) {
            users[userIndex].assignedItemIDs.remove(at: itemIndexInUser)
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
            
            // Add tip portion if tip is enabled
            if isTipEnabled && tipAmountDouble > 0 {
                let userTipShare = tipAmountDouble / Double(users.count)
                userTotal += userTipShare
                userItems.append(ItemDetail(item: "Tip (\(String(format: "%.1f", tipPercentage))%)", cost: userTipShare))
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

// MARK: - ItemAssignmentRow
struct ItemAssignmentRow: View {
    let item: ReceiptItem
    @Binding var users: [User]
    @Binding var items: [ReceiptItem]
    let onAssignmentChange: () -> Void
    @State private var showAssignments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("$\(item.cost, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button("Assign") {
                    showAssignments.toggle()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if showAssignments {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assign to:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(users.indices, id: \.self) { index in
                            let user = users[index]
                            let isAssigned = item.assignedUsers.contains(user.name)
                            
                            Button(action: {
                                toggleAssignment(for: user)
                            }) {
                                HStack {
                                    Image(systemName: isAssigned ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isAssigned ? .blue : .gray)
                                    
                                    Text(user.name)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    isAssigned 
                                    ? Color.blue.opacity(0.1) 
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Show assigned people
            if !item.assignedUsers.isEmpty {
                HStack {
                    Text("Assigned to:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(item.assignedUsers.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func toggleAssignment(for user: User) {
        // Find the item in the items array
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }),
              let userIndex = users.firstIndex(where: { $0.id == user.id }) else { return }
        
        let isCurrentlyAssigned = items[itemIndex].assignedUsers.contains(user.name)
        
        if isCurrentlyAssigned {
            // Remove assignment
            if let assignedUserIndex = items[itemIndex].assignedUsers.firstIndex(of: user.name) {
                items[itemIndex].assignedUsers.remove(at: assignedUserIndex)
            }
            if let assignedItemIndex = users[userIndex].assignedItemIDs.firstIndex(of: item.id) {
                users[userIndex].assignedItemIDs.remove(at: assignedItemIndex)
            }
        } else {
            // Add assignment
            items[itemIndex].assignedUsers.append(user.name)
            users[userIndex].assignedItemIDs.append(item.id)
        }
        
        onAssignmentChange()
    }
}

// MARK: - ItemAssignmentCard (Modern Wheel Design)
struct ItemAssignmentCard: View {
    let item: ReceiptItem
    @Binding var users: [User]
    @Binding var items: [ReceiptItem]
    let onAssignmentChange: () -> Void
    @State private var showAssignments = false
    @EnvironmentObject var currencyManager: CurrencyManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Item Card
            VStack(spacing: 8) {
                // Item Info
                VStack(spacing: 6) {
                    Text(item.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(height: 32)
                    
                    Text(currencyManager.formatAmount(item.cost))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                // Assignment Status
                if !item.assignedUsers.isEmpty {
                    Text("\(item.assignedUsers.count) assigned")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .frame(width: 120, height: 80)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6).opacity(0.6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            
            // Action Button
            Button(action: {
                showAssignments.toggle()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: showAssignments ? "checkmark.circle.fill" : "person.badge.plus")
                        .font(.system(size: 12, weight: .medium))
                    Text(showAssignments ? "Done" : "Assign")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .frame(width: 80, height: 28)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(14)
            }
            
            // Assignment Panel (appears below when expanded)
            if showAssignments {
                VStack(spacing: 8) {
                    Text("Assign to:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    ForEach(users.indices, id: \.self) { index in
                        let user = users[index]
                        let isAssigned = item.assignedUsers.contains(user.name)
                        
                        Button(action: {
                            toggleAssignment(for: user)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: isAssigned ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12))
                                    .foregroundColor(isAssigned ? .blue : .gray)
                                
                                Text(user.name)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                isAssigned 
                                ? Color.blue.opacity(0.1) 
                                : Color(.systemGray6)
                            )
                            .cornerRadius(8)
                        }
                        .frame(width: 100)
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showAssignments)
    }
    
    private func toggleAssignment(for user: User) {
        // Find the item in the items array
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }),
              let userIndex = users.firstIndex(where: { $0.id == user.id }) else { return }
        
        let isCurrentlyAssigned = items[itemIndex].assignedUsers.contains(user.name)
        
        if isCurrentlyAssigned {
            // Remove assignment
            if let assignedUserIndex = items[itemIndex].assignedUsers.firstIndex(of: user.name) {
                items[itemIndex].assignedUsers.remove(at: assignedUserIndex)
            }
            if let assignedItemIndex = users[userIndex].assignedItemIDs.firstIndex(of: item.id) {
                users[userIndex].assignedItemIDs.remove(at: assignedItemIndex)
            }
        } else {
            // Add assignment
            items[itemIndex].assignedUsers.append(user.name)
            users[userIndex].assignedItemIDs.append(item.id)
        }
        
        onAssignmentChange()
    }
}
