import SwiftUI
import UniformTypeIdentifiers

struct ItemAssignmentView: View {
    let items: [ReceiptItem]
    @State private var users: [User] = []

    @State private var newUserName: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
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
            }

            HStack(spacing: 20) {
                // List of items to drag
                List {
                    Section(header: Text("Items")) {
                        ForEach(items, id: \.name) { item in
                            Text(item.name)
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(5)
                                .onDrag {
                                    NSItemProvider(object: item.name as NSString)
                                }
                        }
                    }
                }
                .frame(width: 200)

                // List of users with drop zones
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(users.indices, id: \.self) { index in
                            VStack {
                                Text(users[index].name)
                                    .font(.headline)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)

                                VStack {
                                    ForEach(users[index].assignedItems, id: \.name) { item in
                                        Text(item.name)
                                            .padding()
                                            .background(Color.secondary.opacity(0.1))
                                            .cornerRadius(5)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(Color.secondary.opacity(0.05))
                                .cornerRadius(10)
                                .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                                    handleDrop(for: index, providers: providers)
                                }
                            }
                        }
                    }
                }
                .frame(height: 300)
            }

            Button("Calculate Shares") {
                let shares = calculateUserShares(users: users)
                print("Shares: \(shares)")
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Assign Items")
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

        users.append(User(id: UUID().uuidString, name: newUserName, assignedItems: []))
        newUserName = ""
        errorMessage = nil
    }

    // Handle item drop onto a user
    private func handleDrop(for userIndex: Int, providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: NSString.self) {
                provider.loadObject(ofClass: NSString.self) { object, error in
                    if let itemName = object as? String {
                        if let item = items.first(where: { $0.name == itemName }) {
                            DispatchQueue.main.async {
                                users[userIndex].assignedItems.append(item)
                            }
                        }
                    }
                }
                return true
            }
        }
        return false
    }
    
    // Calculate user shares
    private func calculateUserShares(users: [User]) -> [String: Double] {
        var userShares: [String: Double] = [:]

        for user in users {
            let totalCost = user.assignedItems.reduce(0.0) { $0 + $1.cost }
            userShares[user.name] = totalCost
        }

        return userShares
    }
}
