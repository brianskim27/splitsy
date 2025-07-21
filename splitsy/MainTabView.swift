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
                        VStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 22, weight: .regular))
                            Text("Home")
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == .home ? .accentColor : .gray)
                        .frame(maxWidth: .infinity)
                    }

                    // New (+) tab
                    Button(action: { showNewSplit = true }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22, weight: .regular))
                            Text("New")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    }

                    // Profile tab
                    Button(action: { selectedTab = .profile }) {
                        VStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 22, weight: .regular))
                            Text("Profile")
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == .profile ? .accentColor : .gray)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
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
