import SwiftUI
import Vision
import PhotosUI

struct ReceiptInputView: View {
    @State private var receiptImage: UIImage? = nil
    @State private var parsedItems: [ReceiptItem] = [] // Parsed items
    @State private var detectedTexts: [(id: UUID, text: String, box: CGRect)] = [] // Detected texts with unique IDs
    @State private var isPickerPresented = false // Open picker at start
    @State private var isNavigatingToAssignmentView = false // Tracks navigation

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 📸 Receipt Image Display
                ZStack {
                    if let receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    } else {
                        Color.secondary.opacity(0.1)
                            .frame(height: 300)
                            .cornerRadius(12)
                            .overlay(
                                Text("Tap to Upload or Take a Receipt Photo")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            )
                            .onTapGesture {
                                isPickerPresented = true
                            }
                    }
                }
                .frame(height: 300)
                .padding(.horizontal)

                // 🛒 Parsed Items List
                if !parsedItems.isEmpty {
                    List {
                        ForEach(parsedItems, id: \.id) { item in
                            HStack {
                                Text(item.name)
                                    .font(.body)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Text("$\(item.cost, specifier: "%.2f")")
                                    .foregroundColor(.green)
                                    .font(.body)
                                    .bold()
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: removeItem)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 350)
                }

                Spacer()
            }
            .padding(.bottom, 20)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // 🔙 Back Button (Only Visible After Selection)
                if receiptImage != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            receiptImage = nil // Reset image
                            parsedItems.removeAll() // Clear parsed items
                            isPickerPresented = true // Reopen picker
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        }
                    }
                }

                // 🏷️ Title
                ToolbarItem(placement: .principal) {
                    Text("Analyze Receipt")
                        .font(.headline)
                        .bold()
                }

                // ➡️ Next Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isNavigatingToAssignmentView = true
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isNextButtonEnabled ? .blue : .gray)
                        .opacity(isNextButtonEnabled ? 1.0 : 0.5)
                    }
                    .disabled(!isNextButtonEnabled)
                }
            }
            .navigationDestination(isPresented: $isNavigatingToAssignmentView) {
                ItemAssignmentView(items: parsedItems)
            }
            .sheet(isPresented: $isPickerPresented, onDismiss: {
                if let image = receiptImage {
                    analyzeReceiptImage(image) // 📌 Auto-analyze after selection
                }
            }) {
                ImagePicker(image: $receiptImage)
            }
        }
    }
    
    // ✅ Next button enabled only if there are parsed items
    private var isNextButtonEnabled: Bool {
        return !parsedItems.isEmpty
    }

    // 🗑 Remove Item
    private func removeItem(at offsets: IndexSet) {
        parsedItems.remove(atOffsets: offsets)
    }

    // 🔍 Analyze Receipt with OCR (Automatically triggered)
    private func analyzeReceiptImage(_ image: UIImage) {
        var correctedImage = image
        if image.size.width > image.size.height {
            correctedImage = image.rotated(by: .pi / 2) ?? image
        }
        
        guard let cgImage = correctedImage.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedTexts: [(id: UUID, text: String, box: CGRect)] = []
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    detectedTexts.append((id: UUID(), text: topCandidate.string, box: observation.boundingBox))
                }
            }
            
            DispatchQueue.main.async {
                self.detectedTexts = detectedTexts
                self.parsedItems = groupItemsAndPrices(detectedTexts: detectedTexts.map { ($0.text, $0.box) })
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error.localizedDescription)")
            }
        }
    }

    // 🏷️ Group Items & Prices from OCR Data
    private func groupItemsAndPrices(detectedTexts: [(text: String, box: CGRect)]) -> [ReceiptItem] {
        var items: [ReceiptItem] = []
        let priceRegex = try! NSRegularExpression(pattern: #"^\$?\s*(\d+[.,]\d{2})$"#)
        
        var priceCandidates: [(text: String, box: CGRect)] = []
        var textCandidates: [(text: String, box: CGRect)] = []
        
        for detectedText in detectedTexts {
            let text = detectedText.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if priceRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
                let priceText = text.replacingOccurrences(of: ",", with: ".")
                if let priceValue = Double(priceText.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) {
                    priceCandidates.append((text: String(format: "$%.2f", priceValue), box: detectedText.box))
                }
            } else {
                textCandidates.append(detectedText)
            }
        }
        
        for price in priceCandidates {
            if let matchingText = textCandidates.min(by: { abs($0.box.minX - price.box.minX) < abs($1.box.minX - price.box.minX) }) {
                if let priceValue = Double(price.text.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ".")) {
                    items.append(ReceiptItem(name: matchingText.text, cost: priceValue))
                    textCandidates.removeAll { $0.text == matchingText.text }
                }
            }
        }
        return items
    }
}

// 🗑 Swipe-to-Delete Row
struct SwipeToDeleteRow: View {
    let item: ReceiptItem
    let onDelete: (UUID) -> Void

    var body: some View {
        HStack {
            Text(item.name)
                .font(.body)
                .bold()
                .multilineTextAlignment(.leading)
            Spacer()
            Text("$\(item.cost, specifier: "%.2f")")
                .foregroundColor(.green)
                .font(.body)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .swipeActions {
            Button(role: .destructive) {
                onDelete(item.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

extension UIImage {
    func rotated(by radians: CGFloat) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: size.width / 2, y: size.height / 2)
            context.rotate(by: radians)
            draw(at: CGPoint(x: -size.width / 2, y: -size.height / 2))
        }
    }
}
