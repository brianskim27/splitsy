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
            if receiptImage != nil {
                items.removeAll()
                step = 1
            }
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
        VStack(spacing: 40) {
            Spacer()
            Text("Add a Receipt")
                .font(.largeTitle)
                .bold()
            HStack(spacing: 48) {
                Button(action: onCamera) {
                    VStack {
                        Image(systemName: "camera.fill").font(.system(size: 44))
                        Text("Camera")
                    }
                }
                Button(action: onGallery) {
                    VStack {
                        Image(systemName: "photo.on.rectangle").font(.system(size: 44))
                        Text("Gallery")
                    }
                }
            }
            .foregroundColor(.blue)
            Spacer()
        }
    }
}

// Step 1: Preview Image is now in its own file

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
        ZStack {
            ReviewSplitView(
                userShares: userShares,
                detailedBreakdown: detailedBreakdown,
                onConfirm: onNext
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

// Step 5: Completion
struct CompletionStep: View {
    var onDone: () -> Void
    @State private var animate = false
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.03)]),
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(spacing: 36) {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 110, height: 110)
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.18), radius: 16, x: 0, y: 4)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: animate)
                Text("Split Complete!")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: onDone) {
                    HStack {
                        Spacer()
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(14)
                    .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}
