import SwiftUI

enum Tab {
    case home
    case profile
}

struct MainTabView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @State private var selectedTab: Tab = .home
    @State private var showNewSplit = false

    var body: some View {
        ZStack {
            // Main content
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack { HomeView() }
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            VStack {
                Spacer()
                HStack {
                    // Home tab
                    Button(action: { selectedTab = .home }) {
                        VStack(spacing: 2) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 24, weight: .regular))
                            Text("Home")
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == .home ? .accentColor : .gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .offset(y: 8)
                    }

                    // New (+) tab
                    Button(action: { showNewSplit = true }) {
                        VStack(spacing: 2) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .regular))
                            Text("New")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .offset(y: 8)
                    }

                    // Profile tab
                    Button(action: { selectedTab = .profile }) {
                        VStack(spacing: 2) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24, weight: .regular))
                            Text("Profile")
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == .profile ? .accentColor : .gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .offset(y: 8)
                    }
                }
                .frame(height: 44)
                .padding(.vertical, 8)
                .background(
                    Color(.systemBackground)
                        .ignoresSafeArea(edges: .bottom)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
                )
            }
        }
        .fullScreenCover(isPresented: $showNewSplit) {
            NewSplitFlowView()
        }
    }
}
