import SwiftUI
import UIKit

struct SplitDetailView: View {
    @Environment(\.dismiss) var dismiss
    let split: Split
    @State private var showFullScreen = false
    @State private var showSaveResultAlert = false
    @State private var saveResultMessage: String = ""

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
                        Text("Total: $\(split.totalAmount, specifier: "%.2f")")
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
                                Text("$\(split.userShares[user] ?? 0, specifier: "%.2f")")
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
                                        Text("$\(itemDetail.cost, specifier: "%.2f")")
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
                        saveSplitToPhotos()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    Button("Done") { dismiss() }
                }
            }
            .alert("Export", isPresented: $showSaveResultAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveResultMessage)
            }
        }
    }
}

// MARK: - Export Logic
extension SplitDetailView {
    private func saveSplitToPhotos() {
        let exportView = SplitDetailExportView(split: split)
            .padding(16)
            .frame(width: 900, alignment: .center)
            .background(Color(.systemBackground))

        if let image = renderAsImage(view: exportView) {
            let saver = ImageSaver { success, error in
                if success {
                    saveResultMessage = "Saved to Photos."
                } else {
                    saveResultMessage = "Failed to save: \(error?.localizedDescription ?? "Unknown error")."
                }
                showSaveResultAlert = true
            }
            saver.writeToPhotoAlbum(image: image)
        } else {
            saveResultMessage = "Could not render export image."
            showSaveResultAlert = true
        }
    }

    @MainActor
    private func renderAsImage<V: View>(view: V) -> UIImage? {
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: view)
            renderer.proposedSize = .init(width: 900, height: nil)
            renderer.scale = UIScreen.main.scale
            renderer.isOpaque = true
            return renderer.uiImage
        } else {
            // Fallback for iOS < 16 using UIHostingController snapshot
            let controller = UIHostingController(rootView: view)
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

// MARK: - Exportable View
struct SplitDetailExportView: View {
    let split: Split

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
                Text("Total: $\(split.totalAmount, specifier: "%.2f")")
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
                            Text("$\(split.userShares[user] ?? 0, specifier: "%.2f")")
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
                                        Text("$\(itemDetail.cost, specifier: "%.2f")")
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

// MARK: - ImageSaver Helper
final class ImageSaver: NSObject {
    private let completion: (_ success: Bool, _ error: Error?) -> Void

    init(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.completion = completion
    }

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion(error == nil, error)
    }
}
