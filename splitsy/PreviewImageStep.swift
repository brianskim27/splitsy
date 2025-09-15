import SwiftUI

struct PreviewImageStep: View {
    @Binding var receiptImage: UIImage?
    var onBack: () -> Void
    var onNext: () -> Void
    @State private var showFullScreen = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Preview")
                    .font(.title2)
                    .bold()
                    .padding(.top, 8)
                Spacer()
                if let image = receiptImage {
                    HStack {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 4)
                            .padding(.horizontal, 24)
                            .onTapGesture { showFullScreen = true }
                            .accessibilityLabel("Tap to enlarge receipt image")
                            .sheet(isPresented: $showFullScreen) {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    VStack {
                                        Spacer()
                                        ZoomableImageView(image: image)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        Spacer()
                                        Button("Close") { showFullScreen = false }
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                            }
                        Spacer()
                    }
                } else {
                    Spacer()
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 300)
                        .overlay(Text("[Receipt Image Preview]").foregroundColor(.gray))
                    Spacer()
                }
                Spacer()
                Button(action: {
                    isLoading = true
                    // Add a small delay to show the loading animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onNext()
                    }
                }) {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(14)
                    .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 2)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.top, 12)
        }
    }
} 
