import SwiftUI

struct PlusButtonPositionKey: PreferenceKey {
    static var defaultValue: CGPoint? = nil
    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        value = nextValue() ?? value
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showNewSplit = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                    switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    EmptyView() // New Split is a modal
                case 2:
                    ProfileView()
                default:
                    HomeView()
                    }
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                TabBarButton(icon: "house.fill", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                Spacer()
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .shadow(radius: 6)
                Button(action: {
                        showNewSplit = true
                }) {
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.white))
                    }
                }
                .offset(y: -24)
                Spacer()
                TabBarButton(icon: "person.fill", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                Spacer()
            }
            .frame(height: 80)
            .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
        }
        .sheet(isPresented: $showNewSplit) {
            NewSplitFlowView()
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(width: 44, height: 44)
        }
    }
}

// UIKit blur for SwiftUI
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
