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
            let yourShare = split.userShares["Brian"] ?? 0
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
