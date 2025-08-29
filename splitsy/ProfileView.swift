import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showNewSplit = false
    @State private var showHistory = false
    @State private var showHistoryFullScreen = false
    @State private var showSignOutAlert = false
    @State private var showEditProfile = false
    @State private var showAccountSettings = false
    @State private var showNotifications = false
    @State private var showHelpSupport = false
    @State private var showDataExport = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Profile Header
                profileHeader
                
                // User Statistics
                userStatistics
                
                // Quick Actions
                quickActions
                
                // Account & Settings
                accountSettings
                
                // App Features
                appFeatures
                
                // Support & Help
                supportSection
                
                // Sign Out
                signOutButton
            }
            .padding(.horizontal)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showAccountSettings) {
            AccountSettingsView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $showHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showDataExport) {
            DataExportView()
                .environmentObject(splitHistoryManager)
        }
        .fullScreenCover(isPresented: $showNewSplit) {
            NewSplitFlowView()
        }
        .fullScreenCover(isPresented: $showHistoryFullScreen) {
            NavigationView {
                HistoryView()
                    .environmentObject(splitHistoryManager)
                    .navigationTitle("History")
                    .navigationBarTitleDisplayMode(.large)
                    .navigationBarBackButtonHidden(false)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                showHistoryFullScreen = false
                            }
                        }
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(spacing: 16) {
            // Profile Picture
            Button(action: {
                // TODO: Add profile picture upload
            }) {
                ZStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 25, y: 25)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authManager.currentUser?.name ?? "User")
                    .font(.title2)
                    .bold()
                
                if let username = authManager.currentUser?.username, !username.isEmpty {
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Text(authManager.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("Verified Account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                showEditProfile = true
            }) {
                Image(systemName: "pencil")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.top)
    }
    
    // MARK: - User Statistics
    private var userStatistics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Stats")
                .font(.headline)
                .bold()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ProfileStatCard(
                    title: "Total Spent",
                    value: formatCurrency(totalSpent),
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                ProfileStatCard(
                    title: "Money Saved",
                    value: formatCurrency(moneySaved),
                    icon: "arrow.down.circle.fill",
                    color: .blue
                )
                
                ProfileStatCard(
                    title: "Total Splits",
                    value: "\(splitHistoryManager.pastSplits.count)",
                    icon: "chart.pie.fill",
                    color: .orange
                )
                
                ProfileStatCard(
                    title: "Avg. Split",
                    value: formatCurrency(averageSplit),
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .bold()
            
            VStack(spacing: 8) {
                ProfileButton(
                    title: "New Split",
                    subtitle: "Create a new expense split",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    showNewSplit = true
                }
                
                ProfileButton(
                    title: "View History",
                    subtitle: "See all your past splits",
                    icon: "clock.fill",
                    color: .green
                ) {
                    showHistoryFullScreen = true
                }
            }
        }
    }
    
    // MARK: - Account Settings
    private var accountSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account & Settings")
                .font(.headline)
                .bold()
            
            VStack(spacing: 8) {
                ProfileButton(
                    title: "Account Settings",
                    subtitle: "Manage your account preferences",
                    icon: "person.circle",
                    color: .blue
                ) {
                    showAccountSettings = true
                }
                
                ProfileButton(
                    title: "Notifications",
                    subtitle: "Configure notification preferences",
                    icon: "bell",
                    color: .orange
                ) {
                    showNotifications = true
                }
                
                ProfileButton(
                    title: "Data Export",
                    subtitle: "Export your split history",
                    icon: "square.and.arrow.up",
                    color: .purple
                ) {
                    showDataExport = true
                }
            }
        }
    }
    
    // MARK: - App Features
    private var appFeatures: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Features")
                .font(.headline)
                .bold()
            
            VStack(spacing: 8) {
                ProfileButton(
                    title: "Split Templates",
                    subtitle: "Save and reuse common splits",
                    icon: "doc.on.doc",
                    color: .green
                ) {
                    // TODO: Implement split templates
                }
                
                ProfileButton(
                    title: "Favorite Contacts",
                    subtitle: "Manage your frequent split partners",
                    icon: "star.fill",
                    color: .yellow
                ) {
                    // TODO: Implement favorite contacts
                }
            }
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support & Help")
                .font(.headline)
                .bold()
            
            VStack(spacing: 8) {
                ProfileButton(
                    title: "Help & Support",
                    subtitle: "Get help and contact support",
                    icon: "questionmark.circle",
                    color: .blue
                ) {
                    showHelpSupport = true
                }
                
                ProfileButton(
                    title: "About Splitsy",
                    subtitle: "App version and information",
                    icon: "info.circle",
                    color: .gray
                ) {
                    // TODO: Implement about view
                }
            }
        }
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button(action: {
            showSignOutAlert = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
                Spacer()
            }
            .font(.headline)
            .foregroundColor(.red)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Computed Properties
    private var totalSpent: Double {
        splitHistoryManager.pastSplits.reduce(0) { $0 + $1.totalAmount }
    }
    
    private var moneySaved: Double {
        splitHistoryManager.pastSplits.reduce(0) { total, split in
            let yourShare = split.userShares["Brian"] ?? 0
            let fullAmount = split.totalAmount
            return total + (fullAmount - yourShare)
        }
    }
    
    private var averageSplit: Double {
        let count = splitHistoryManager.pastSplits.count
        return count > 0 ? totalSpent / Double(count) : 0
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return String(format: "$%.2f", amount)
    }
}

// MARK: - Supporting Views

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProfileButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Placeholder Views (to be implemented)

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isCheckingUsername = false
    @State private var usernameAvailable = false
    @State private var showUsernameTaken = false
    @State private var showSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Edit Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Update your display name and username")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Display Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your display name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Username
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if let currentUser = authManager.currentUser {
                                if currentUser.canChangeUsername {
                                    Text("Can change")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(4)
                                } else {
                                    Text("\(currentUser.daysUntilUsernameChange) days")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        
                        HStack {
                            Text("@")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)
                            
                            TextField("username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .disabled(!canChangeUsername)
                                .onChange(of: username) { oldValue, newValue in
                                    // Remove spaces and special characters
                                    let filtered = newValue.lowercased().replacingOccurrences(of: " ", with: "")
                                        .replacingOccurrences(of: "[^a-z0-9_]", with: "", options: .regularExpression)
                                    if filtered != newValue {
                                        username = filtered
                                    }
                                    
                                    // Check username availability
                                    if !filtered.isEmpty && canChangeUsername {
                                        checkUsernameAvailability(filtered)
                                    } else {
                                        usernameAvailable = false
                                        showUsernameTaken = false
                                    }
                                }
                            
                            if isCheckingUsername {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.trailing, 12)
                            } else if !username.isEmpty && canChangeUsername {
                                Image(systemName: usernameAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(usernameAvailable ? .green : .red)
                                    .padding(.trailing, 12)
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        if showUsernameTaken {
                            Text("Username is already taken")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if usernameAvailable && !username.isEmpty && canChangeUsername {
                            Text("Username is available")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else if !username.isEmpty && canChangeUsername {
                            Text("Username must be 3-20 characters, letters, numbers, and underscores only")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if !canChangeUsername {
                            Text("You can change your username once every 7 days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Save button
                Button(action: {
                    showSaveConfirmation = true
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Save Changes")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .disabled(isLoading || !isFormValid)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadCurrentData()
        }
        .alert("Save Changes", isPresented: $showSaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Save", role: .destructive) {
                saveChanges()
            }
        } message: {
            Text("Are you sure you want to save these changes to your profile?")
        }
    }
    
    private var canChangeUsername: Bool {
        authManager.currentUser?.canChangeUsername ?? false
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isCheckingUsername
    }
    
    private func loadCurrentData() {
        if let currentUser = authManager.currentUser {
            name = currentUser.name
            username = currentUser.username
        }
    }
    
    private func checkUsernameAvailability(_ username: String) {
        guard username.count >= 3 else {
            usernameAvailable = false
            showUsernameTaken = false
            return
        }
        
        isCheckingUsername = true
        showUsernameTaken = false
        
        Task {
            let isAvailable = await authManager.checkUsernameAvailability(username)
            
            await MainActor.run {
                self.usernameAvailable = isAvailable
                self.isCheckingUsername = false
                if !isAvailable {
                    self.showUsernameTaken = true
                }
            }
        }
    }
    
    private func saveChanges() {
        guard isFormValid else { return }
        
        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let newUsername = username.isEmpty ? nil : username.lowercased()
        
        // Validate username if user is trying to change it
        if let currentUser = authManager.currentUser,
           let newUsername = newUsername,
           newUsername != currentUser.username {
            
            // Check if username change is allowed
            if !currentUser.canChangeUsername {
                errorMessage = "You can only change your username once every 7 days. Please wait \(currentUser.daysUntilUsernameChange) more days."
                return
            }
            
            // Check if username is valid
            if newUsername.count < 3 || newUsername.count > 20 {
                errorMessage = "Username must be between 3 and 20 characters."
                return
            }
            
            // Check if username is available
            if !usernameAvailable {
                errorMessage = "Username is not available. Please choose a different one."
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            await authManager.updateProfile(name: displayName, username: newUsername)
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Account Settings")
                    .font(.title)
                    .bold()
                
                Text("Account settings coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Notifications")
                    .font(.title)
                    .bold()
                
                Text("Notification settings coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Help & Support")
                    .font(.title)
                    .bold()
                
                Text("Help and support coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DataExportView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Data Export")
                    .font(.title)
                    .bold()
                
                Text("Data export coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
