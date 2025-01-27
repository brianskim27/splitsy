import SwiftUI
import Vision
import PhotosUI

struct ReceiptInputView: View {
    @State private var receiptImage: UIImage? = nil
    @State private var parsedItems: [ReceiptItem] = [] // Parsed items
    @State private var detectedTexts: [(id: UUID, text: String, box: CGRect)] = [] // Detected texts with unique IDs
    @State private var isPickerPresented = false
    @State private var isNavigatingToAssignmentView = false // Tracks navigation
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if let receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit() // Maintain aspect ratio
                            .frame(height: 300)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else {
                        Text("Upload or Take a Photo of a Receipt")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                            .onTapGesture {
                                isPickerPresented = true
                            }
                    }
                }
                .frame(height: 300)
                
                if !parsedItems.isEmpty {
                    ScrollView {
                        ForEach(parsedItems, id: \.id) { item in
                            HStack {
                                Text(item.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("$\(item.cost, specifier: "%.2f")")
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .frame(height: 200)
                }
                
                Button("Analyze Receipt") {
                    if let image = receiptImage {
                        analyzeReceiptImage(image)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(receiptImage == nil)
                
                // NavigationLink to ItemAssignmentView
                NavigationLink(
                    destination: ItemAssignmentView(items: parsedItems),
                    isActive: $isNavigatingToAssignmentView
                ) {
                    EmptyView() // Hidden link, controlled programmatically
                }
                .hidden() // Keep it hidden
                
                Button("Proceed to Assign Items") {
                    isNavigatingToAssignmentView = true // Trigger navigation
                }
                .buttonStyle(.borderedProminent)
                .disabled(parsedItems.isEmpty) // Enable only after analyzing
            }
            .padding()
            .navigationTitle("Receipt Input")
            .sheet(isPresented: $isPickerPresented) {
                ImagePicker(image: $receiptImage)
            }
        }
    }
    
    private func analyzeReceiptImage(_ image: UIImage) {
        // Your OCR and parsing logic
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
    
    private func groupItemsAndPrices(detectedTexts: [(text: String, box: CGRect)]) -> [ReceiptItem] {
        var items: [ReceiptItem] = []
        
        // Regex to identify prices (handles both commas and periods as decimal separators)
        let priceRegex = try! NSRegularExpression(pattern: #"^\$?\s*(\d+[.,]\d{2})$"#)
        
        // Separate price candidates and general text
        var priceCandidates: [(text: String, box: CGRect)] = []
        var textCandidates: [(text: String, box: CGRect)] = []
        
        for detectedText in detectedTexts {
            let text = detectedText.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Detect prices
            if priceRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
                // Normalize price format
                let priceText = text.replacingOccurrences(of: ",", with: ".")
                if let priceValue = Double(priceText.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) {
                    priceCandidates.append((text: String(format: "$%.2f", priceValue), box: detectedText.box))
                }
            } else {
                // All other text as potential items
                textCandidates.append(detectedText)
            }
        }
        
        // Debugging: Print detected prices and text candidates with their coordinates
        print("Detected Prices with Coordinates:")
        for price in priceCandidates {
            print("Text: \(price.text), Coordinates: \(price.box)")
        }
        
        print("\nDetected Texts with Coordinates:")
        for text in textCandidates {
            print("Text: \(text.text), Coordinates: \(text.box)")
        }
        
        // Step 2: Match items to prices based on closest X-value
        for price in priceCandidates {
            if let matchingText = textCandidates.min(by: { lhs, rhs in
                // Compare the absolute difference in X-coordinates
                let lhsXDifference = abs(lhs.box.minX - price.box.minX)
                let rhsXDifference = abs(rhs.box.minX - price.box.minX)
                return lhsXDifference < rhsXDifference
            }) {
                if let priceValue = Double(price.text.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ".")) {
                    // Add matched item
                    items.append(ReceiptItem(name: matchingText.text, cost: priceValue))
                    
                    // Remove matched text to prevent duplicate pairing
                    if let index = textCandidates.firstIndex(where: { $0.text == matchingText.text }) {
                        textCandidates.remove(at: index)
                    }
                }
            }
        }
        
        // Debug final parsed items
        print("\nFinal Parsed Items:")
        items.forEach { print("Item: \($0.name), Price: \($0.cost)") }
        
        return items
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
