import SwiftUI

struct ReviewSplitView: View {
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    @State private var splitName: String = ""
    let onConfirm: (String) -> Void
    @FocusState private var isSplitNameFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User breakdowns
                    VStack(spacing: 16) {
                        ForEach(userShares.keys.sorted(), id: \.self) { user in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.7))
                                        .frame(width: 32, height: 32)
                                        .overlay(Text(userInitials(user)).foregroundColor(.white).font(.headline))
                                    Text(user)
                                        .font(.headline)
                                        .bold()
                                    Spacer()
                                    Text("$\(userShares[user] ?? 0.0, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                                
                                if let items = detailedBreakdown[user] {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(items, id: \.self) { itemDetail in
                                            HStack {
                                                Text(itemDetail.item)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text("$\(itemDetail.cost, specifier: "%.2f")")
                                                    .font(.subheadline)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    .padding(.leading, 44)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Split name input
                    VStack(spacing: 16) {
                        TextField("Split name", text: $splitName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isSplitNameFocused)
                            .padding(.horizontal)
                        
                        Button(action: { onConfirm(splitName) }) {
                            HStack {
                                Spacer()
                                Text("Confirm")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(splitName.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(14)
                            .shadow(color: (splitName.isEmpty ? Color.gray : Color.blue).opacity(0.18), radius: 8, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .disabled(splitName.isEmpty)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 12)
            }
            .padding(.bottom, keyboardHeight)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Review")
                    .font(.title2)
                    .bold()
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
}
