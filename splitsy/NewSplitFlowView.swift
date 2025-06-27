import SwiftUI

struct NewSplitFlowView: View {
    @Environment(\.dismiss) var dismiss
    @State private var step: Int = 0
    @State private var receiptImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var imagePickerSource: ImagePickerSourceType = .photoLibrary
    @State private var proceedFromReceiptInput = false
    @State private var proceedFromAssignment = false
    @State private var items: [ReceiptItem] = []
    @State private var userShares: [String: Double] = [:]
    @State private var detailedBreakdown: [String: [(item: String, cost: Double)]] = [:]
    @State private var users: [User] = []

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch step {
                case 0:
                    ChooseSourceStep(
                        onCamera: {
                            imagePickerSource = .camera
                            showImagePicker = true
                        },
                        onGallery: {
                            imagePickerSource = .photoLibrary
                            showImagePicker = true
                        }
                    )
                case 1:
                    PreviewImageStep(receiptImage: $receiptImage, onBack: { step = 0 }, onNext: { step += 1 })
                case 2:
                    ReceiptInputStep(
                        receiptImage: $receiptImage,
                        proceed: $proceedFromReceiptInput,
                        parsedItems: $items,
                        onBack: { step -= 1 }
                    )
                case 3:
                    ItemAssignmentStep(
                        items: $items,
                        users: $users,
                        proceed: $proceedFromAssignment,
                        userShares: $userShares,
                        detailedBreakdown: $detailedBreakdown,
                        onBack: { step -= 1 }
                    )
                case 4:
                    ReviewSplitStep(
                        userShares: userShares,
                        detailedBreakdown: detailedBreakdown,
                        onBack: { step -= 1 },
                        onNext: { step += 1 }
                    )
                case 5:
                    CompletionStep(onDone: { dismiss() })
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .sheet(isPresented: $showImagePicker, onDismiss: {
            if receiptImage != nil { step = 1 }
        }) {
            ImagePicker(image: $receiptImage, sourceType: imagePickerSource)
        }
        .onChange(of: proceedFromReceiptInput) { oldValue, newValue in
            if newValue {
                step = 3
                proceedFromReceiptInput = false
            }
        }
        .onChange(of: proceedFromAssignment) { oldValue, newValue in
            if newValue {
                step = 4
                proceedFromAssignment = false
            }
        }
    }
}

// Step 0: Choose Source
struct ChooseSourceStep: View {
    var onCamera: () -> Void
    var onGallery: () -> Void
    var body: some View {
        VStack(spacing: 32) {
            Text("Add a Receipt")
                .font(.title)
                .bold()
            HStack(spacing: 40) {
                Button(action: onCamera) {
                    VStack {
                        Image(systemName: "camera.fill").font(.system(size: 40))
                        Text("Camera")
                    }
                }
                Button(action: onGallery) {
                    VStack {
                        Image(systemName: "photo.on.rectangle").font(.system(size: 40))
                        Text("Gallery")
                    }
                }
            }
            Spacer()
        }
    }
}

// Step 1: Preview Image
struct PreviewImageStep: View {
    @Binding var receiptImage: UIImage?
    var onBack: () -> Void
    var onNext: () -> Void
    @State private var showFullScreen = false
    var body: some View {
        VStack(spacing: 24) {
            Text("Preview Receipt")
                .font(.title2)
                .bold()
            if let image = receiptImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .onTapGesture { showFullScreen = true }
                    .accessibilityLabel("Tap to enlarge receipt image")
                    .sheet(isPresented: $showFullScreen) {
                        ZStack {
                            Color.black.ignoresSafeArea()
                            VStack {
                                Spacer()
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                Spacer()
                                Button("Close") { showFullScreen = false }
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                    }
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(Text("[Receipt Image Preview]").foregroundColor(.gray))
            }
            HStack {
                Button("Back", action: onBack)
                Spacer()
                Button("Next", action: onNext)
            }
            Spacer()
        }
    }
}

// Step 2: ReceiptInputView wrapper for flow control
struct ReceiptInputStep: View {
    @Binding var receiptImage: UIImage?
    @Binding var proceed: Bool
    @Binding var parsedItems: [ReceiptItem]
    var onBack: () -> Void
    var body: some View {
        ZStack {
            ReceiptInputView(receiptImage: $receiptImage, parsedItems: $parsedItems, onNext: { _ in proceed = true })
            VStack {
                HStack {
                    Button("Back", action: onBack)
                        .padding(.top, 8)
                        .padding(.leading, 8)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// Step 3: ItemAssignmentView wrapper for flow control
struct ItemAssignmentStep: View {
    @Binding var items: [ReceiptItem]
    @Binding var users: [User]
    @Binding var proceed: Bool
    @Binding var userShares: [String: Double]
    @Binding var detailedBreakdown: [String: [(item: String, cost: Double)]]
    var onBack: () -> Void
    var body: some View {
        ZStack {
            ItemAssignmentView(
                items: $items,
                users: $users,
                onComplete: { shares, breakdown in
                    userShares = shares
                    detailedBreakdown = breakdown
                    proceed = true
                }
            )
            VStack {
                HStack {
                    Button("Back", action: onBack)
                        .padding(.top, 8)
                        .padding(.leading, 8)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// Step 4: Review Split
struct ReviewSplitStep: View {
    let userShares: [String: Double]
    let detailedBreakdown: [String: [(item: String, cost: Double)]]
    var onBack: () -> Void
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Review Split")
                .font(.title2)
                .bold()
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(userShares.keys.sorted(), id: \.self) { user in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.7))
                                    .frame(width: 32, height: 32)
                                    .overlay(Text(userInitials(user)).foregroundColor(.white).font(.headline))
                                Text(user)
                                    .font(.headline)
                                    .bold()
                                Spacer()
                                Text("$\(userShares[user] ?? 0.0, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            if let items = detailedBreakdown[user] {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(items, id: \.item) { itemDetail in
                                        HStack {
                                            Text(itemDetail.item)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(itemDetail.cost, specifier: "%.2f")")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                .padding(.leading, 44)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Confirm Button
            Button(action: onNext) {
                HStack {
                    Spacer()
                    Text("Confirm Split")
                        .font(.headline)
                        .foregroundColor(.white)
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(14)
                .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            HStack {
                Button("Back", action: onBack)
                    .padding()
                Spacer()
            }
        }
        .padding(.top, 12)
    }
    
    // Helper for initials
    private func userInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count == 1, let first = parts.first?.first {
            return String(first).uppercased()
        } else if let first = parts.first?.first, let last = parts.last?.first {
            return String(first).uppercased() + String(last).uppercased()
        } else {
            return "?"
        }
    }
}

// Step 5: Completion
struct CompletionStep: View {
    var onDone: () -> Void
    var body: some View {
        VStack(spacing: 32) {
            Text("Split Complete!")
                .font(.title)
                .bold()
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            Button("Done", action: onDone)
                .padding()
            Spacer()
        }
    }
}
