import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo and title
                        VStack(spacing: 16) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Splitsy")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Split bills with friends, easily")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                        
                        // Login form
                        VStack(spacing: 20) {
                            // Email or Username field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email or Username")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter your email or username", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
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
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .password)
                                    .onSubmit {
                                        signIn()
                                    }
                            }
                            
                            // Error message
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Sign in button
                            Button(action: signIn) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Sign In")
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
                            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                            
                            // Forgot password
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 32)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            Text("or")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal, 32)
                        
                        // Social Sign In buttons
                        VStack(spacing: 12) {
                            // Apple Sign In button
                            /*
                            Button(action: {
                                authManager.signInWithApple()
                            }) {
                                HStack {
                                    Image(systemName: "applelogo")
                                        .font(.title2)
                                    Text("Sign in with Apple")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(authManager.isLoading)
                            */
                            
                            // Google Sign In button
                            Button(action: {
                                authManager.signInWithGoogle()
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .font(.title2)
                                    Text("Sign in with Google")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                            .disabled(authManager.isLoading)
                        }
                        
                        // Sign up button
                        Button("Create Account") {
                            showSignUp = true
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authManager)
        }
    }
    
    private func signIn() {
        authManager.signIn(emailOrUsername: email, password: password)
    }
}

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($isEmailFocused)
                }
                
                // Error message
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Reset button
                Button(action: resetPassword) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Send Reset Link")
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
                }
                .disabled(authManager.isLoading || email.isEmpty)
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetPassword() {
        authManager.resetPassword(email: email)
    }
}
