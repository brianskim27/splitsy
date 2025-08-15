import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showNewSplit = false
    @State private var showHistory = false
    @State private var showHistoryFullScreen = false
    @State private var showSignOutAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(authManager.currentUser?.name ?? "User")
                        .font(.title)
                        .bold()
                    Text(authManager.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.top)

            // Link to full history
            Button(action: {
                showHistoryFullScreen = true
            }) {
                HStack {
                    Image(systemName: "clock.fill")
                    Text("History")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Account settings
            VStack(spacing: 12) {
                Button(action: {
                    // Handle account settings
                }) {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Account Settings")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    // Handle notifications
                }) {
                    HStack {
                        Image(systemName: "bell")
                        Text("Notifications")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    // Handle help & support
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Help & Support")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            // Sign out button
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
        }
        .padding(.horizontal)
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
}
