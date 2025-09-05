import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @State private var showNewSplit = false
    @State private var showHistory = false
    @State private var showHistoryFullScreen = false
    @State private var showSignOutAlert = false
    @State private var showEditProfile = false
    @State private var showAccountSettings = false
    @State private var showNotifications = false
    @State private var showHelpSupport = false
    @State private var showDataExport = false
    @State private var showFeedback = false
    @State private var showCurrencySelection = false
    @State private var showAbout = false

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
                

                
                // Support & Help
                supportSection
                
                // Sign Out
                signOutButton
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
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
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showDataExport) {
            DataExportView()
                .environmentObject(splitHistoryManager)
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
        .sheet(isPresented: $showCurrencySelection) {
            CurrencySelectionView()
                .environmentObject(currencyManager)
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
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
            ZStack {
                if let profilePictureURL = authManager.currentUser?.profilePictureURL,
                   let url = URL(string: profilePictureURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
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
                    title: "Currency",
                    subtitle: "\(currencyManager.selectedCurrency.symbol) \(currencyManager.selectedCurrency.name)",
                    icon: "dollarsign.circle",
                    color: .green
                ) {
                    showCurrencySelection = true
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
    

    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support & Help")
                .font(.headline)
                .bold()
            
            VStack(spacing: 8) {
                ProfileButton(
                    title: "Send Feedback",
                    subtitle: "Report bugs or suggest features",
                    icon: "envelope",
                    color: .green
                ) {
                    showFeedback = true
                }
                
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
                    showAbout = true
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
        .padding(.bottom, 80)
    }
    
    // MARK: - Computed Properties
    private var totalSpent: Double {
        splitHistoryManager.pastSplits.reduce(0) { total, split in
            total + currencyManager.getConvertedAmountSync(split.totalAmount, from: split.originalCurrency)
        }
    }
    
    private var moneySaved: Double {
        splitHistoryManager.pastSplits.reduce(0) { total, split in
            let yourShare = split.userShares[authManager.currentUser?.name ?? ""] ?? 0
            let fullAmount = split.totalAmount
            
            // Convert both amounts to current currency
            let convertedFullAmount = currencyManager.getConvertedAmountSync(fullAmount, from: split.originalCurrency)
            let convertedYourShare = currencyManager.getConvertedAmountSync(yourShare, from: split.originalCurrency)
            
            return total + (convertedFullAmount - convertedYourShare)
        }
    }
    
    private var averageSplit: Double {
        let count = splitHistoryManager.pastSplits.count
        return count > 0 ? totalSpent / Double(count) : 0
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return currencyManager.formatAmount(amount)
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
    @State private var showImagePicker = false
    @State private var showImageSourceSheet = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerSourceType: ImagePickerSourceType = .photoLibrary
    
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
                    // Profile Picture
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Profile Picture")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            // Profile Picture Display
                                        Button(action: {
                showImageSourceSheet = true
            }) {
                                ZStack {
                                    if let profilePictureURL = authManager.currentUser?.profilePictureURL,
                                       let url = URL(string: profilePictureURL) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                                .foregroundColor(.blue)
                                        }
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(.blue)
                                    }
                                    
                                                        Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 25, y: 25)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tap to change")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Text("Choose from camera or photo library")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imagePickerSourceType)
        }
        .sheet(isPresented: $showImageSourceSheet) {
            ImageSourceSheet(
                showImagePicker: $showImagePicker,
                imagePickerSourceType: $imagePickerSourceType,
                hasProfilePicture: authManager.currentUser?.profilePictureURL != nil,
                authManager: authManager
            )
        }
        .onChange(of: selectedImage) { _, newImage in
            print("📸 ProfileView: Image selected - \(newImage != nil ? "Image present" : "No image")")
            if let image = newImage {
                print("📸 ProfileView: Starting upload process...")
                Task {
                    await authManager.uploadProfilePicture(image)
                    selectedImage = nil
                }
            }
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
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAccountAlert = false
    @State private var showPasswordResetAlert = false
    
    private var emailVerificationSubtitle: String {
        authManager.isEmailVerified() ? "Email verified" : "Email not verified"
    }
    
    private var emailVerificationColor: Color {
        authManager.isEmailVerified() ? .green : .orange
    }
    
    private var isEmailVerified: Bool {
        authManager.isEmailVerified()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Account Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account Information")
                            .font(.headline)
                            .bold()
                        
                        VStack(spacing: 12) {
                            InfoRow(title: "Email", value: authManager.currentUser?.email ?? "N/A")
                            InfoRow(title: "Username", value: "@\(authManager.currentUser?.username ?? "N/A")")
                            InfoRow(title: "Display Name", value: authManager.currentUser?.name ?? "N/A")
                            InfoRow(title: "Member Since", value: formatDate(authManager.currentUser?.createdAt))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Security Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Security")
                            .font(.headline)
                            .bold()
                        
                        VStack(spacing: 8) {
                            SettingsButton(
                                title: "Reset Password",
                                subtitle: "Send password reset email",
                                icon: "lock.rotation",
                                color: .blue
                            ) {
                                showPasswordResetAlert = true
                            }
                            
                            SettingsButton(
                                title: "Email Verification",
                                subtitle: emailVerificationSubtitle,
                                icon: "checkmark.shield",
                                color: emailVerificationColor
                            ) {
                                if !isEmailVerified {
                                    authManager.sendEmailVerification()
                                }
                            }
                        }
                    }
                    
                    // Data Management Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data Management")
                            .font(.headline)
                            .bold()
                        
                        VStack(spacing: 8) {
                            SettingsButton(
                                title: "Export Data",
                                subtitle: "Download your split history",
                                icon: "square.and.arrow.up",
                                color: .purple
                            ) {
                                // TODO: Implement data export
                            }
                            
                            SettingsButton(
                                title: "Delete Account",
                                subtitle: "Permanently delete your account and data",
                                icon: "trash",
                                color: .red
                            ) {
                                showDeleteAccountAlert = true
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset Password", isPresented: $showPasswordResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Send Reset Email") {
                    if let email = authManager.currentUser?.email {
                        authManager.resetPassword(email: email)
                    }
                }
            } message: {
                Text("We'll send a password reset link to your email address.")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // TODO: Implement account deletion
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

struct SettingsButton: View {
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
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
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
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory = .gettingStarted
    @State private var showContactSupport = false
    
    enum HelpCategory: String, CaseIterable {
        case gettingStarted = "Getting Started"
        case faq = "FAQ"
        case troubleshooting = "Troubleshooting"
        case contact = "Contact Support"
        
        var icon: String {
            switch self {
            case .gettingStarted: return "play.circle.fill"
            case .faq: return "questionmark.circle.fill"
            case .troubleshooting: return "wrench.and.screwdriver.fill"
            case .contact: return "envelope.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .gettingStarted: return .blue
            case .faq: return .green
            case .troubleshooting: return .orange
            case .contact: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Category Picker
                categoryPicker
                
                // Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        switch selectedCategory {
                        case .gettingStarted:
                            gettingStartedContent
                        case .faq:
                            faqContent
                        case .troubleshooting:
                            troubleshootingContent
                        case .contact:
                            contactContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
        .sheet(isPresented: $showContactSupport) {
            ContactSupportView()
                .environmentObject(authManager)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search help topics...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Category Picker
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(HelpCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Getting Started Content
    private var gettingStartedContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(title: "Welcome to Splitsy!") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Splitsy makes splitting bills effortless with AI-powered receipt scanning. Here's how to get started:")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    HelpStep(
                        number: 1,
                        title: "Take a Photo",
                        description: "Point your camera at a receipt and tap the capture button. Our AI will automatically detect and extract items and prices."
                    )
                    
                    HelpStep(
                        number: 2,
                        title: "Review Items",
                        description: "Check the detected items and prices. You can edit any item or add missing ones manually."
                    )
                    
                    HelpStep(
                        number: 3,
                        title: "Assign Items",
                        description: "Tap on items to assign them to different people. The app will calculate totals automatically."
                    )
                    
                    HelpStep(
                        number: 4,
                        title: "Add Tips & Tax",
                        description: "Include tips and tax as needed. Choose between percentage or fixed amounts."
                    )
                    
                    HelpStep(
                        number: 5,
                        title: "Share Results",
                        description: "Review the final split and share the results with your group."
                    )
                }
            }
            
            HelpSection(title: "Quick Tips") {
                VStack(alignment: .leading, spacing: 8) {
                    TipRow(icon: "camera.fill", text: "Ensure good lighting when taking receipt photos")
                    TipRow(icon: "textformat", text: "Receipt text should be clear and readable")
                    TipRow(icon: "person.2.fill", text: "Add people before assigning items for easier organization")
                    TipRow(icon: "dollarsign.circle.fill", text: "Set your preferred currency in Profile > Currency")
                }
            }
        }
    }
    
    // MARK: - FAQ Content
    private var faqContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(title: "Frequently Asked Questions") {
                VStack(spacing: 12) {
                    FAQItem(
                        question: "How accurate is the receipt scanning?",
                        answer: "Our AI-powered scanning is highly accurate for most receipts. However, results may vary with poor lighting, blurry photos, or unusual receipt formats. You can always manually edit detected items."
                    )
                    
                    FAQItem(
                        question: "Can I split bills in different currencies?",
                        answer: "Yes! Splitsy supports multiple currencies with real-time conversion rates. Set your preferred currency in Profile > Currency, and the app will handle conversions automatically."
                    )
                    
                    FAQItem(
                        question: "Is my data secure?",
                        answer: "Absolutely. We use Firebase for secure data storage and encryption. Your personal information and split history are protected with industry-standard security measures."
                    )
                    
                    FAQItem(
                        question: "Can I export my split history?",
                        answer: "Yes, you can export your split history from Profile > Data Export. This feature allows you to download your data for personal records or backup purposes."
                    )
                    
                    FAQItem(
                        question: "What if the app doesn't detect an item correctly?",
                        answer: "You can manually edit any detected item by tapping on it. You can also add new items manually if they weren't detected from the receipt."
                    )
                    
                    FAQItem(
                        question: "Does Splitsy work offline?",
                        answer: "Core functionality works offline, but you'll need an internet connection for receipt scanning, currency conversion, and data synchronization."
                    )
                }
            }
        }
    }
    
    // MARK: - Troubleshooting Content
    private var troubleshootingContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(title: "Common Issues") {
                VStack(spacing: 16) {
                    TroubleshootingItem(
                        issue: "Receipt scanning not working",
                        solutions: [
                            "Ensure good lighting and clear receipt text",
                            "Try taking the photo from a different angle",
                            "Make sure the receipt is flat and not wrinkled",
                            "Check that your internet connection is stable"
                        ]
                    )
                    
                    TroubleshootingItem(
                        issue: "App crashes or freezes",
                        solutions: [
                            "Force close and restart the app",
                            "Restart your device",
                            "Check for app updates in the App Store",
                            "Clear app cache by signing out and back in"
                        ]
                    )
                    
                    TroubleshootingItem(
                        issue: "Currency conversion not updating",
                        solutions: [
                            "Check your internet connection",
                            "Try switching to a different currency and back",
                            "Restart the app to refresh exchange rates",
                            "Ensure you're using the latest app version"
                        ]
                    )
                    
                    TroubleshootingItem(
                        issue: "Can't sign in with Google",
                        solutions: [
                            "Check your internet connection",
                            "Make sure you're using the correct Google account",
                            "Try signing out and back in",
                            "Restart the app and try again"
                        ]
                    )
                }
            }
            
            HelpSection(title: "Still Need Help?") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("If you're still experiencing issues, our support team is here to help.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showContactSupport = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Contact Support")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Content
    private var contactContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(title: "Get in Touch") {
                VStack(spacing: 16) {
                    ContactOption(
                        icon: "envelope.fill",
                        title: "Email Support",
                        subtitle: "Get help via email",
                        action: {
                            if let url = URL(string: "mailto:splitsy.contact@gmail.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                    
                    ContactOption(
                        icon: "star.fill",
                        title: "Rate Splitsy",
                        subtitle: "Help us improve on the App Store",
                        action: {
                            // TODO: Add App Store rating URL when available
                        }
                    )
                    
                    ContactOption(
                        icon: "heart.fill",
                        title: "Send Feedback",
                        subtitle: "Share your thoughts and suggestions",
                        action: {
                            showContactSupport = true
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CategoryButton: View {
    let category: HelpSupportView.HelpCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color : Color(.systemGray6))
            )
        }
    }
}

struct HelpSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HelpStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TroubleshootingItem: View {
    let issue: String
    let solutions: [String]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    
                    Text(issue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(solutions.enumerated()), id: \.offset) { index, solution in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.accentColor)
                                .fontWeight(.bold)
                            
                            Text(solution)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ContactOption: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
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


struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showFeedbackForm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Support")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Choose how you'd like to get in touch with our support team.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Contact Options
                    VStack(spacing: 16) {
                        ContactSupportOption(
                            icon: "envelope.fill",
                            title: "Email Support",
                            subtitle: "Get help via email",
                            description: "Send us an email and we'll respond within 24-48 hours",
                            action: {
                                if let url = URL(string: "mailto:splitsy.contact@gmail.com") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        ContactSupportOption(
                            icon: "text.bubble.fill",
                            title: "Send Feedback",
                            subtitle: "Report bugs or suggest features",
                            description: "Use our detailed feedback form to help us improve",
                            action: {
                                showFeedbackForm = true
                            }
                        )
                        
                        ContactSupportOption(
                            icon: "star.fill",
                            title: "Rate Splitsy",
                            subtitle: "Help us improve on the App Store",
                            description: "Your ratings help other users discover Splitsy",
                            action: {
                                // TODO: Add App Store rating URL when available
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showFeedbackForm) {
            FeedbackView()
                .environmentObject(authManager)
        }
    }
}

struct ContactSupportOption: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
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

struct ImageSourceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showImagePicker: Bool
    @Binding var imagePickerSourceType: ImagePickerSourceType
    let hasProfilePicture: Bool
    let authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Profile Picture")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Choose how you'd like to update your profile picture")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Options
                VStack(spacing: 0) {
                    // Camera option
                    Button(action: {
                        imagePickerSourceType = .camera
                        showImagePicker = true
                        dismiss()
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Take Photo")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    .background(Color.white)
                    
                    Divider()
                        .padding(.leading, 64)
                    
                    // Photo Library option
                    Button(action: {
                        imagePickerSourceType = .photoLibrary
                        showImagePicker = true
                        dismiss()
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Choose from Library")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    .background(Color.white)
                    
                    // Remove photo option (only show if user has a profile picture)
                    if hasProfilePicture {
                        Divider()
                            .padding(.leading, 64)
                        
                        Button(action: {
                            Task {
                                await authManager.removeProfilePicture()
                                dismiss()
                            }
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "trash.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .frame(width: 24)
                                
                                Text("Remove Photo")
                                    .font(.body)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }
                        .background(Color.white)
                    }
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
    }
}



struct GridLines: View {
    var body: some View {
        ZStack {
            // Vertical lines
            ForEach(1..<3) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1)
                    .frame(maxWidth: .infinity)
                    .offset(x: CGFloat(i) * 93.33 - 140) // Divide 280 by 3
            }
            
            // Horizontal lines
            ForEach(1..<3) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                    .frame(maxHeight: .infinity)
                    .offset(y: CGFloat(i) * 93.33 - 140) // Divide 280 by 3
            }
        }
        .frame(width: 280, height: 280)
        .allowsHitTesting(false)
    }
}

