import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var showEmailSignIn = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo and title
                        VStack(spacing: 16) {
                            Image("app_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .cornerRadius(16)
                            
                            Text("Splitsy")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Because math shouldn't ruin your dinner plans")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                        
                        if showEmailSignIn {
                            // Email/Username Sign In Form
                            VStack(alignment: .leading, spacing: 20) {
                                // Back button
                                Button(action: {
                                    showEmailSignIn = false
                                    email = ""
                                    password = ""
                                    authManager.errorMessage = nil
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Back")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.blue)
                                }
                                
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
                        } else {
                            // Main Sign In Options
                            VStack(spacing: 16) {
                                // Sign in with Email/Username button
                                Button(action: {
                                    showEmailSignIn = true
                                    focusedField = .email
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.blue)
                                        
                                        Text("Sign in with Email/Username")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 20)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                                
                                // Sign in with Google button
                                Button(action: {
                                    authManager.signInWithGoogle()
                                }) {
                                    HStack(spacing: 12) {
                                        Image("google_logo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 18, height: 18)
                                        
                                        Text("Sign in with Google")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 20)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                                .disabled(authManager.isLoading)
                            }
                            .padding(.horizontal, 32)
                            
                            // Create Account button
                            VStack(spacing: 8) {
                                Text("Don't have an account?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button("Create Account") {
                                    showSignUp = true
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.light)
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping anywhere
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
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
            .preferredColorScheme(.light)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        // Dismiss keyboard when tapping anywhere
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
        }
    }
    
    private func resetPassword() {
        authManager.resetPassword(email: email)
    }
}
