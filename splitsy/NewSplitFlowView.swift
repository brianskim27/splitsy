import SwiftUI
import LinkPresentation

struct NewSplitFlowView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    
    @State private var step: Int = 0
    @State private var receiptImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var imagePickerSource: ImagePickerSourceType = .photoLibrary
    @State private var proceedFromReceiptInput = false
    @State private var proceedFromAssignment = false
    @State private var items: [ReceiptItem] = []
    @State private var userShares: [String: Double] = [:]
    @State private var detailedBreakdown: [String: [ItemDetail]] = [:]
    @State private var users: [User] = []
    @State private var splitName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    switch step {
                    case 0:
                        ChooseSourceStep(
                            onCamera: {
                                showCamera = true
                            },
                            onGallery: {
                                showGallery = true
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
                            onNext: { name in
                                splitName = name
                                let newSplit = Split(
                                    description: name.isEmpty ? nil : name,
                                    totalAmount: userShares.values.reduce(0, +),
                                    userShares: userShares,
                                    detailedBreakdown: detailedBreakdown,
                                    receiptImage: receiptImage
                                )
                                splitHistoryManager.addSplit(newSplit)
                                step += 1
                            }
                        )
                    case 5:
                        CompletionStep(
                            splitName: splitName,
                            userShares: userShares,
                            detailedBreakdown: detailedBreakdown,
                            receiptImage: receiptImage,
                            onDone: { dismiss() }
                        )
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .sheet(isPresented: $showCamera, onDismiss: {
                if receiptImage != nil {
                    items.removeAll()
                    step = 1
                }
            }) {
                ImagePicker(image: $receiptImage, sourceType: .camera)
            }
            .sheet(isPresented: $showGallery, onDismiss: {
                if receiptImage != nil {
                    items.removeAll()
                    step = 1
                }
            }) {
                ImagePicker(image: $receiptImage, sourceType: .photoLibrary)
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if step == 0 {
                        Button("Cancel") {
                            dismiss()
                        }
                    } else if step > 0 && step < 5 {
                        Button(action: { step -= 1 }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
            }
        }
    }
}

// Choose Source
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

// ReceiptInputView wrapper for flow control
struct ReceiptInputStep: View {
    @Binding var receiptImage: UIImage?
    @Binding var proceed: Bool
    @Binding var parsedItems: [ReceiptItem]
    var onBack: () -> Void
    var body: some View {
        ZStack {
            ReceiptInputView(receiptImage: $receiptImage, parsedItems: $parsedItems, onNext: { _ in proceed = true })
        }
    }
}

// ItemAssignmentView wrapper for flow control
struct ItemAssignmentStep: View {
    @Binding var items: [ReceiptItem]
    @Binding var users: [User]
    @Binding var proceed: Bool
    @Binding var userShares: [String: Double]
    @Binding var detailedBreakdown: [String: [ItemDetail]]
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
        }
    }
}

// Review Split
struct ReviewSplitStep: View {
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    var onBack: () -> Void
    var onNext: (String) -> Void

    var body: some View {
        ZStack {
            ReviewSplitView(
                userShares: userShares,
                detailedBreakdown: detailedBreakdown,
                onConfirm: onNext
            )
        }
    }
}

// Completion
struct CompletionStep: View {
    let splitName: String
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    let receiptImage: UIImage?
    var onDone: () -> Void
    @State private var isPreparingShare = false
    
    private var total: Double {
        userShares.values.reduce(0, +)
    }
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Header Info
                    VStack(spacing: 8) {
                        Text(splitName.isEmpty ? "Split" : splitName)
                            .font(.title2)
                            .bold()
                        Text(Date(), style: .date)
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Text("Total: $\(total, specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)

                    // User Breakdowns
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
                                Text("$\(userShares[user] ?? 0, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }

                            if let personItems = detailedBreakdown[user] {
                                ForEach(personItems, id: \.self) { itemDetail in
                                    HStack {
                                        Text(itemDetail.item)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("$\(itemDetail.cost, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.leading, 44)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await prepareAndPresentShareSheet()
                    }
                } label: {
                    if isPreparingShare {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(isPreparingShare)
                
                Button("Done") { onDone() }
            }
        }
    }
    
    @MainActor
    private func prepareAndPresentShareSheet() async {
        isPreparingShare = true
        
        guard let splitImage = renderSplitAsImage() else {
            isPreparingShare = false
            return
        }
        
        // Get the current view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            isPreparingShare = false
            return
        }
        
        // Find the topmost view controller
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        // Create custom share sheet with large image preview
        let customShareController = CustomShareViewController(image: splitImage)
        
        isPreparingShare = false
        topController.present(customShareController, animated: true)
    }
    
    @MainActor
    private func renderSplitAsImage() -> UIImage? {
        let exportView = SplitExportView(
            splitName: splitName,
            userShares: userShares,
            detailedBreakdown: detailedBreakdown,
            total: total
        )
        .padding(16)
        .frame(width: 900, alignment: .center)
        .background(Color(.systemBackground))
        
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: exportView)
            renderer.proposedSize = .init(width: 900, height: nil)
            renderer.scale = UIScreen.main.scale
            renderer.isOpaque = true
            return renderer.uiImage
        } else {
            let controller = UIHostingController(rootView: exportView)
            let targetSize = CGSize(width: 900, height: UIView.layoutFittingCompressedSize.height)
            controller.view.bounds = CGRect(origin: .zero, size: targetSize)
            controller.view.backgroundColor = .systemBackground
            let size = controller.sizeThatFits(in: CGSize(width: targetSize.width, height: CGFloat.greatestFiniteMagnitude))
            controller.view.bounds.size = size

            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { _ in
                controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
    }
}

// MARK: - Split Export View
struct SplitExportView: View {
    let splitName: String
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    let total: Double
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 6) {
                Text(splitName.isEmpty ? "Split" : splitName)
                    .font(.title2)
                    .bold()
                Text(Date(), style: .date)
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text("Total: $\(total, specifier: "%.2f")")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)

            VStack(spacing: 16) {
                ForEach(userShares.keys.sorted(), id: \.self) { user in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            Circle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: 24, height: 24)
                                .overlay(Text(userInitials(user)).foregroundColor(.white).font(.caption).bold())
                            Text(user)
                                .font(.headline)
                                .bold()
                            Spacer()
                            Text("$\(userShares[user] ?? 0, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        if let items = detailedBreakdown[user] {
                            VStack(spacing: 8) {
                                ForEach(items, id: \.self) { itemDetail in
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(itemDetail.item)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("$\(itemDetail.cost, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.leading, 32)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}


