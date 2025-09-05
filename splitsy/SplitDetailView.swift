import SwiftUI
import UIKit
import LinkPresentation

struct SplitDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var currencyManager: CurrencyManager
    let split: Split
    @State private var showFullScreen = false
    @State private var isPreparingShare = false
    

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Receipt Image
                    if let imageData = split.receiptImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 360)
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onTapGesture { showFullScreen = true }
                            .sheet(isPresented: $showFullScreen) {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    VStack {
                                        Spacer()
                                        ZoomableImageView(image: uiImage)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        Spacer()
                                        Button("Close") { showFullScreen = false }
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                            }
                    }
                    
                    // Header Info
                    VStack(spacing: 8) {
                        Text(split.description ?? "Split Details")
                            .font(.title2)
                            .bold()
                        Text(split.date, style: .date)
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Text(currencyManager.formatConvertedAmountSync(split.totalAmount, from: split.originalCurrency))
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)

                    // User Breakdowns
                    ForEach(split.userShares.keys.sorted(), id: \.self) { user in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(user)
                                    .font(.headline)
                                    .bold()
                                Spacer()
                                Text(currencyManager.formatConvertedAmountSync(split.userShares[user] ?? 0, from: split.originalCurrency))
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }

                            if let items = split.detailedBreakdown[user] {
                                ForEach(items, id: \.self) { itemDetail in
                                    HStack {
                                        Text(itemDetail.item)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(currencyManager.formatConvertedAmountSync(itemDetail.cost, from: split.originalCurrency))
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.leading)
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
            .navigationTitle("Split Details")
            .navigationBarTitleDisplayMode(.inline)
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
                    Button("Done") { dismiss() }
                }
            }

        }
    }
}

// MARK: - Share Logic
extension SplitDetailView {
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
        let customShareController = SplitDetailCustomShareViewController(image: splitImage, split: split)
        
        isPreparingShare = false
        topController.present(customShareController, animated: true)
    }
}

// MARK: - Custom Share View Controller
class SplitDetailCustomShareViewController: UIViewController {
    private let image: UIImage
    private let split: Split
    private var activityViewController: UIActivityViewController?
    
    init(image: UIImage, split: Split) {
        self.image = image
        self.split = split
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .pageSheet
        
        if let sheetController = self.sheetPresentationController {
            sheetController.detents = [.large()]
            sheetController.selectedDetentIdentifier = .large
            sheetController.prefersGrabberVisible = true
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetController.prefersEdgeAttachedInCompactHeight = true
            sheetController.preferredCornerRadius = 20
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        // Create container stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add export label
        let exportLabel = UILabel()
        exportLabel.text = "Export"
        exportLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        exportLabel.textAlignment = .center
        exportLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create tappable image container
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.backgroundColor = .systemGray6
        imageContainer.layer.cornerRadius = 16
        imageContainer.clipsToBounds = true
        
        // Add large image preview
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        
        // Add tap gesture for zoom
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        imageContainer.addSubview(imageView)
        
        // Create activity view controller
        let imageSource = SplitDetailImageActivityItemSource(image: image, split: split)
        activityViewController = UIActivityViewController(
            activityItems: [imageSource],
            applicationActivities: nil
        )
        
        guard let activityViewController = activityViewController else { return }
        
        activityViewController.excludedActivityTypes = []
        activityViewController.modalPresentationStyle = .none
        
        // Add activity controller as child
        addChild(activityViewController)
        activityViewController.view.translatesAutoresizingMaskIntoConstraints = false
        activityViewController.view.backgroundColor = .clear
        
        // Add completion handler to dismiss when done
        activityViewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.dismiss(animated: true)
        }
        
        // Add views to stack
        stackView.addArrangedSubview(exportLabel)
        stackView.addArrangedSubview(imageContainer)
        stackView.addArrangedSubview(activityViewController.view)
        
        view.addSubview(stackView)
        
        // Setup constraints with wider layout
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // Make image container much larger
            imageContainer.heightAnchor.constraint(equalToConstant: 300),
            
            // Image view fills container with padding
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: -12),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: -12),
            
            activityViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])
        
        activityViewController.didMove(toParent: self)
    }
    
    @objc private func imageViewTapped() {
        let zoomView = ZoomableImageView(image: image)
        let hostingController = UIHostingController(rootView: 
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            self.dismiss(animated: true)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    zoomView
                        .onTapGesture {
                            self.dismiss(animated: true)
                        }
                }
            }
        )
        
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
}

// MARK: - Split Detail Image Activity Item Source
class SplitDetailImageActivityItemSource: NSObject, UIActivityItemSource {
    private let image: UIImage
    private let split: Split
    
    init(image: UIImage, split: Split) {
        self.image = image
        self.split = split
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return split.description ?? "Split Details"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "public.image"
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = split.description ?? "Split Details"
        
        let imageProvider = NSItemProvider(object: image)
        metadata.imageProvider = imageProvider
        
        return metadata
    }
}

// MARK: - Exportable View
struct SplitDetailExportView: View {
    let split: Split
    @EnvironmentObject var currencyManager: CurrencyManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let imageData = split.receiptImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 520)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            VStack(spacing: 6) {
                Text(split.description ?? "Split Details")
                    .font(.title2)
                    .bold()
                Text(split.date, style: .date)
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text(currencyManager.formatConvertedAmountSync(split.totalAmount, from: split.originalCurrency))
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)

            VStack(spacing: 16) {
                ForEach(split.userShares.keys.sorted(), id: \.self) { user in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(user)
                                .font(.headline)
                                .bold()
                            Spacer()
                            Text(currencyManager.formatConvertedAmountSync(split.userShares[user] ?? 0, from: split.originalCurrency))
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        if let items = split.detailedBreakdown[user] {
                            VStack(spacing: 8) {
                                ForEach(items, id: \.self) { itemDetail in
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(itemDetail.item)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(currencyManager.formatConvertedAmountSync(itemDetail.cost, from: split.originalCurrency))
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
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



extension SplitDetailView {
    @MainActor
    private func renderSplitAsImage() -> UIImage? {
        let exportView = SplitDetailExportView(split: split)
            .environmentObject(currencyManager)
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
            // Fallback for iOS < 16
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
