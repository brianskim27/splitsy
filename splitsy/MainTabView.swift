import SwiftUI

struct PlusButtonPositionKey: PreferenceKey {
    static var defaultValue: CGPoint? = nil
    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        value = nextValue() ?? value
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showImagePickerSheet = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var receiptImage: UIImage? = nil
    @State private var showReceiptInput = false
    @State private var lastTab = 0
    @State private var plusButtonPosition: CGPoint? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case 0: HomeView()
                    case 1: ListView()
                    case 3: HistoryView()
                    case 4: ProfileView()
                    default: HomeView()
                    }
                }
                MinimalTabBar(selectedTab: $selectedTab, showImagePickerSheet: $showImagePickerSheet)
            }
            .zIndex(0)

            ZStack {
                // Dimmed background
                if showImagePickerSheet {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation(.spring()) { showImagePickerSheet = false } }
                }
                // Camera Button
                Button(action: {
                    showCamera = true
                    withAnimation(.spring()) { showImagePickerSheet = false }
                }) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .offset(
                    x: showImagePickerSheet ? -54 * cos(.pi / 3) : 0,
                    y: showImagePickerSheet ? -54 * sin(.pi / 3) - 20 : 0 // -20 to lift above tab bar
                )
                .scaleEffect(showImagePickerSheet ? 1 : 0.1)
                .opacity(showImagePickerSheet ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showImagePickerSheet)

                // Gallery Button
                Button(action: {
                    showGallery = true
                    withAnimation(.spring()) { showImagePickerSheet = false }
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .offset(
                    x: showImagePickerSheet ? 54 * cos(.pi / 3) : 0,
                    y: showImagePickerSheet ? -54 * sin(.pi / 3) - 20 : 0
                )
                .scaleEffect(showImagePickerSheet ? 1 : 0.1)
                .opacity(showImagePickerSheet ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showImagePickerSheet)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 30) // adjust so it sits just above the tab bar
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .zIndex(2)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $receiptImage, sourceType: .camera)
                .onDisappear {
                    if receiptImage != nil {
                        showReceiptInput = true
                    }
                }
        }
        .sheet(isPresented: $showGallery) {
            ImagePicker(image: $receiptImage, sourceType: .photoLibrary)
                .onDisappear {
                    if receiptImage != nil {
                        showReceiptInput = true
                    }
                }
        }
        .fullScreenCover(isPresented: $showReceiptInput) {
            ReceiptInputView(receiptImage: $receiptImage)
        }
    }
}

struct MinimalTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showImagePickerSheet: Bool
    let tabBarIcons = [
        "house.fill",
        "list.bullet",
        "plus",
        "clock.fill",
        "person.fill"
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { i in
                if i == 2 {
                    GeometryReader { geo in
                        Button(action: {
                            withAnimation(.spring()) {
                                showImagePickerSheet.toggle()
                            }
                        }) {
                            Image(systemName: tabBarIcons[i])
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(selectedTab == i ? Color.blue : Color.gray)
                                .frame(maxWidth: .infinity, maxHeight: 44)
                        }
                        .anchorPreference(key: PlusButtonPositionKey.self, value: .center) { anchor in
                            geo[anchor]
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 44)
                } else {
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTab = i
                        }
                    }) {
                        Image(systemName: tabBarIcons[i])
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(selectedTab == i ? Color.blue : Color.gray)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                    }
                }
            }
        }
        .frame(height: 60)
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
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
