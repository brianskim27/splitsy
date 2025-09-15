import SwiftUI

struct UsernameSetupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isCheckingUsername = false
    @State private var usernameAvailable = false
    @State private var showUsernameTaken = false
    
    let email: String?
    let password: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "at.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Choose Your Username")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Pick a unique username that will be your handle on Splitsy")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    // Display Name (only show for manual signup)
                    if email != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your display name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                    }
                    
                    // Username
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("@")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)
                            
                            TextField("username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: username) { oldValue, newValue in
                                    // Remove spaces and special characters
                                    let filtered = newValue.lowercased().replacingOccurrences(of: " ", with: "")
                                        .replacingOccurrences(of: "[^a-z0-9_]", with: "", options: .regularExpression)
                                    if filtered != newValue {
                                        username = filtered
                                    }
                                    
                                    // Check username availability
                                    if !filtered.isEmpty {
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
                            } else if !username.isEmpty {
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
                        } else if usernameAvailable && !username.isEmpty {
                            Text("Username is available")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else if !username.isEmpty {
                            Text("Username must be 3-20 characters, letters, numbers, and underscores only")
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
                
                // Continue button
                Button(action: createAccount) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(email != nil ? "Create Account" : "Complete Setup")
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
                .opacity(isLoading || !isFormValid ? 0.6 : 1.0)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping anywhere
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }
    
    private var isFormValid: Bool {
        let nameValid = email != nil ? !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : true
        return nameValid &&
        username.count >= 3 &&
        username.count <= 20 &&
        usernameAvailable &&
        !isCheckingUsername
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
    
    private func createAccount() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let usernameLower = username.lowercased()
        
        Task {
            // First, check if username is still available
            let isAvailable = await authManager.checkUsernameAvailability(usernameLower)
            
            if !isAvailable {
                await MainActor.run {
                    errorMessage = "Username is no longer available. Please choose another one."
                    isLoading = false
                    showUsernameTaken = true
                    usernameAvailable = false
                }
                return
            }
            
            // Check if this is a manual signup (has email and password) or existing user setup
            if let email = email, let password = password {
                // Manual signup - create account with username
                await authManager.signUpWithUsername(
                    email: email,
                    password: password,
                    name: displayName,
                    username: usernameLower
                )
            } else {
                // Existing user (from email verification or Google signup) - just complete username setup
                authManager.completeUsernameSetup(username: usernameLower)
            }
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}
