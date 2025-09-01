import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showUsernameSetup = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword, name
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Create Account")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Join Splitsy to start splitting bills with friends")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Sign up form
                    VStack(spacing: 20) {
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your full name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .name)
                                .onSubmit {
                                    focusedField = .email
                                }
                        }
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($focusedField, equals: .email)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Create a password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }
                            
                            Text("Must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Confirm password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .confirmPassword)
                                .onSubmit {
                                    signUp()
                                }
                        }
                        
                        // Error message
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Sign up button
                        Button(action: signUp) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Account")
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
                        .disabled(authManager.isLoading || !isFormValid)
                        
                        // Terms and privacy
                        VStack(spacing: 8) {
                            Text("By creating an account, you agree to our")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Button("Terms of Service") {
                                    // Handle terms of service
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                
                                Text("and")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Privacy Policy") {
                                    // Handle privacy policy
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .preferredColorScheme(.light)
            .fullScreenCover(isPresented: $showUsernameSetup) {
                UsernameSetupView(email: email, password: password)
                    .environmentObject(authManager)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        !name.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func signUp() {
        guard isFormValid else { return }
        showUsernameSetup = true
    }
}
