import SwiftUI
import Vision
import PhotosUI

struct ReceiptInputView: View {
    @Binding var receiptImage: UIImage?
    @Binding var parsedItems: [ReceiptItem]
    var onNext: (([ReceiptItem]) -> Void)? = nil
    @State private var detectedTexts: [(id: UUID, text: String, box: CGRect)] = [] // Detected texts with unique IDs
    @State private var isPickerPresented = false // Open picker at start
    @State private var isNavigatingToAssignmentView = false // Tracks navigation
    @State private var isCameraPresented = false // Add state for camera
    @State private var showFullScreenImage = false
    @State private var editingItemId: UUID? = nil
    @State private var editingItemName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Receipt Image Display
                ZStack {
                    if let receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .background(Color(.systemBackground))
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .onTapGesture { showFullScreenImage = true }
                            .accessibilityLabel("Tap to enlarge receipt image")
                            .sheet(isPresented: $showFullScreenImage) {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    VStack {
                                        Spacer()
                                        Image(uiImage: receiptImage)
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                        Spacer()
                                        Button("Close") { showFullScreenImage = false }
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                            }
                    } else {
                        Color.secondary.opacity(0.08)
                            .frame(height: 220)
                            .cornerRadius(18)
                            .overlay(
                                VStack(spacing: 24) {
                                    Text("Analyze Receipt")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(Color.primary.opacity(0.8))
                                    HStack(spacing: 24) {
                                        Button(action: { isCameraPresented = true }) {
                                            VStack {
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(.white)
                                                    .padding(18)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                                Text("Take Photo")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        Button(action: { isPickerPresented = true }) {
                                            VStack {
                                                Image(systemName: "photo.on.rectangle")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(.white)
                                                    .padding(18)
                                                    .background(Color.green)
                                                    .clipShape(Circle())
                                                Text("Choose from Gallery")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                }
                            )
                    }
                }
                .padding(.horizontal)

                // Parsed Items List
                if !parsedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Parsed Items")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        ScrollView {
                            VStack(spacing: 0) {
                        ForEach(parsedItems, id: \.id) { item in
                            HStack {
                                        if editingItemId == item.id {
                                            TextField("Item Name", text: $editingItemName, onCommit: {
                                                renameItem(id: item.id, newName: editingItemName)
                                                editingItemId = nil
                                            })
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .frame(minWidth: 80, maxWidth: 180)
                                            .font(.body.bold())
                                        } else {
                                Text(item.name)
                                    .font(.body)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                        }
                                Text("$\(item.cost, specifier: "%.2f")")
                                    .foregroundColor(.green)
                                            .font(.subheadline)
                                    .bold()
                                            .padding(.leading, 8)
                                        Spacer()
                                        Button(action: {
                                            editingItemId = item.id
                                            editingItemName = item.name
                                        }) {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.trailing, 4)
                                        Button(action: { removeItemById(item.id) }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .padding(8)
                                        }
                                        .accessibilityLabel("Delete item")
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .frame(maxHeight: 260)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    .padding(.horizontal)
                }

                Spacer()

                // Prominent Next Button
                Button(action: {
                    isNavigatingToAssignmentView = true
                    onNext?(parsedItems)
                }) {
                    HStack {
                        Spacer()
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(isNextButtonEnabled ? Color.blue : Color.gray)
                    .cornerRadius(14)
                    .shadow(color: isNextButtonEnabled ? Color.blue.opacity(0.18) : .clear, radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .disabled(!isNextButtonEnabled)
                .opacity(isNextButtonEnabled ? 1.0 : 0.5)
            }
            .padding(.top, 12)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Analyze Receipt")
                        .font(.headline)
                        .bold()
                }
            }
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(image: $receiptImage, sourceType: .camera)
            }
            .sheet(isPresented: $isPickerPresented, onDismiss: {
                if let image = receiptImage {
                    analyzeReceiptImage(image)
                }
            }) {
                ImagePicker(image: $receiptImage, sourceType: .photoLibrary)
            }
        }
        .onAppear {
            if let image = receiptImage, parsedItems.isEmpty {
                analyzeReceiptImage(image)
            }
        }
        .onChange(of: receiptImage) { oldValue, newValue in
            if let image = newValue, newValue != oldValue {
                parsedItems.removeAll()
                analyzeReceiptImage(image)
            }
        }
    }
    
    // Next button enabled only if there are parsed items
    private var isNextButtonEnabled: Bool {
        return !parsedItems.isEmpty
    }

    // Remove Item by ID (for button delete)
    private func removeItemById(_ id: UUID) {
        if let idx = parsedItems.firstIndex(where: { $0.id == id }) {
            parsedItems.remove(at: idx)
        }
    }

    // Analyze Receipt with OCR (Automatically triggered)
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
                for (i, t) in detectedTexts.enumerated() {
                    print("\(i): \(t.text)")
                }
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform OCR: \(error)")
        }
    }

    // Group Items & Prices from OCR Data
    private func groupItemsAndPrices(detectedTexts: [(text: String, box: CGRect)]) -> [ReceiptItem] {
        let allText = detectedTexts.map { $0.text }.joined(separator: " ").lowercased()
        if allText.contains("walmart") {
            print("Walmart")
            return parseWalmartReceipt(detectedTexts)
        } else if allText.contains("bj's") || allText.contains("bjs") || allText.contains("bi's") || allText.contains("bis") {
            return parseBJsReceipt(detectedTexts)
        } else {
            return parseDefaultReceipt(detectedTexts)
        }
    }
    
    // Parse Walmart receipt
    private func parseWalmartReceipt(_ detectedTexts: [(text: String, box: CGRect)]) -> [ReceiptItem] {
        let priceRegex = try! NSRegularExpression(pattern: #"(\d+[.,]\d{2})(?:\s*[A-Z0-9]*)?$"#, options: [.caseInsensitive])
        let codeWithNameRegex = try! NSRegularExpression(pattern: #"^(.+?)\s+(\d{6,}.*F?)$"#)
        let codeOnlyRegex = try! NSRegularExpression(pattern: #"^\d{6,}.*F?$"#)
        let letterRegex = try! NSRegularExpression(pattern: #"[A-Za-z]"#)
        let ignoreKeywords = [
            "change", "due", "purchase", "tend", "card", "debit", "credit", "savings", "deposit",
            "st#", "op#", "tr#", "tc#", "items sold"
        ]

        let texts = detectedTexts.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
        var items: [ReceiptItem] = []
        var itemNameQueue: [String] = []
        var inProductSection = false
        var foundSubtotal = false
        var foundTax = false
        var foundTotal = false

        for (i, text) in texts.enumerated() {
            let lower = text.lowercased()
            if ignoreKeywords.contains(where: { lower.contains($0) }) { continue }

            // Before handling subtotal/tax/total, flush any pending name lines as an item
            if (lower.contains("subtotal") && !foundSubtotal) || (lower.contains("tax") && !foundTax) || (lower.contains("total") && !foundTotal) {
                // Look for price on this line or next line
                var priceText: String? = nil
                if let match = priceRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
                   let swiftRange = Range(match.range(at: 1), in: text) {
                    priceText = String(text[swiftRange]).replacingOccurrences(of: ",", with: ".")
                } else if i+1 < texts.count {
                    let nextText = texts[i+1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if let match = priceRegex.firstMatch(in: nextText, options: [], range: NSRange(nextText.startIndex..., in: nextText)),
                       !nextText.lowercased().contains("subtotal") && !nextText.lowercased().contains("total") && !nextText.lowercased().contains("tax") {
                        priceText = String(nextText[Range(match.range(at: 1), in: nextText)!]).replacingOccurrences(of: ",", with: ".")
                    }
                }
                if let priceString = priceText, let price = Double(priceString) {
                    if lower.contains("subtotal") && !foundSubtotal {
                        items.append(ReceiptItem(name: text, cost: price))
                        foundSubtotal = true
                    } else if lower.contains("tax") && !foundTax {
                        items.append(ReceiptItem(name: text, cost: price))
                        foundTax = true
                    } else if lower.contains("total") && !foundTotal {
                        items.append(ReceiptItem(name: text, cost: price))
                        foundTotal = true
                    }
                    continue
                }
            }
            // --- END SUBTOTAL, TAX, TOTAL HANDLING ---

            // Detect start of product section
            if !inProductSection {
                if let _ = codeWithNameRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                    inProductSection = true
                } else if
                    letterRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil,
                    i+1 < texts.count,
                    codeOnlyRegex.firstMatch(in: texts[i+1], options: [], range: NSRange(texts[i+1].startIndex..., in: texts[i+1])) != nil {
                    inProductSection = true
                }
                if !inProductSection { continue }
            }

            // If line has both name and code
            if let match = codeWithNameRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let nameRange = Range(match.range(at: 1), in: text) {
                let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
                itemNameQueue.append(name)
                continue
            }

            // If line is a price, pair with first item in queue
            if let match = priceRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let swiftRange = Range(match.range(at: 1), in: text),
               !itemNameQueue.isEmpty {
                let priceString = String(text[swiftRange]).replacingOccurrences(of: ",", with: ".")
                if let price = Double(priceString) {
                    let name = itemNameQueue.removeFirst()
                    items.append(ReceiptItem(name: name, cost: price))
                }
                continue
            }

            // If line is just a name (not a code, not a price)
            if letterRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil &&
                codeOnlyRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) == nil &&
                priceRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) == nil {
                itemNameQueue.append(text)
                continue
            }
        }
        return items
    }

    // Parse BJs receipt
    private func parseBJsReceipt(_ detectedTexts: [(text: String, box: CGRect)]) -> [ReceiptItem] {
        let priceRegex = try! NSRegularExpression(pattern: #"(\d+[.,]\d{2})\s*[A-Z]?$"#, options: [.caseInsensitive])
        let codeRegex = try! NSRegularExpression(pattern: #"^\d{7,}$"#) // 7+ digit code
        let letterRegex = try! NSRegularExpression(pattern: #"[A-Za-z]"#)
        let ignoreKeywords = [
            "change", "due", "purchase", "tend", "card", "debit", "credit", "savings", "st#",
            "op#", "tr#", "tc#", "items sold", "entry", "approved", "auth", "terminal", "number", "aid", "verified", "by pin"
        ]

        let texts = detectedTexts.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
        var items: [ReceiptItem] = []
        var inProductSection = false
        var itemNameQueue: [String] = []
        var pendingNameLines: [String] = []

        for (_, text) in texts.enumerated() {
            let lower = text.lowercased()
            if ignoreKeywords.contains(where: { lower.contains($0) }) { continue }
            if text.isEmpty { continue }

            // Start product section at first code line
            if !inProductSection {
                if codeRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil {
                    inProductSection = true
                } else {
                    continue
                }
            }

            // Before handling subtotal/tax/total, flush any pending name lines as an item
            if (lower.contains("subtotal") || lower.contains("tax") || lower.contains("total")) && !pendingNameLines.isEmpty {
                let name = pendingNameLines.joined(separator: " ")
                itemNameQueue.append(name)
                pendingNameLines.removeAll()
            }

            // If code line, flush any pending name lines as a single item
            if codeRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil {
                if !pendingNameLines.isEmpty {
                    let name = pendingNameLines.joined(separator: " ")
                    itemNameQueue.append(name)
                    pendingNameLines.removeAll()
                }
                continue
            }

            // If price line, flush any pending name lines first, then pair with first item in queue
            if let match = priceRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let swiftRange = Range(match.range(at: 1), in: text) {
                if !pendingNameLines.isEmpty {
                    let name = pendingNameLines.joined(separator: " ")
                    itemNameQueue.append(name)
                    pendingNameLines.removeAll()
                }
                if !itemNameQueue.isEmpty {
                    let priceString = String(text[swiftRange]).replacingOccurrences(of: ",", with: ".")
                    if let price = Double(priceString) {
                        let name = itemNameQueue.removeFirst()
                        if !isProbablyNotItem(name) {
                            items.append(ReceiptItem(name: name, cost: price))
                        }
                    }
                }
                continue
            }

            // If line is just a name (not code, not price)
            if letterRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil &&
                codeRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) == nil &&
                priceRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) == nil {
                pendingNameLines.append(text)
                continue
            }
        }
        // Flush any remaining pending name lines (in case the last item has no code after it)
        if !pendingNameLines.isEmpty {
            let name = pendingNameLines.joined(separator: " ")
            if !isProbablyNotItem(name) {
                itemNameQueue.append(name)
            }
            pendingNameLines.removeAll()
        }
        return items
    }

    // Parse normal receipt
    private func parseDefaultReceipt(_ detectedTexts: [(text: String, box: CGRect)]) -> [ReceiptItem] {
        // Use your original logic here
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

    private func reconstructLinesWithFragments(from detectedTexts: [(text: String, box: CGRect)]) -> [[(text: String, box: CGRect)]] {
        let sorted = detectedTexts.sorted {
            abs($0.box.midY - $1.box.midY) < 0.005
                ? $0.box.minX < $1.box.minX
                : $0.box.midY < $1.box.midY
        }
        var lines: [[(text: String, box: CGRect)]] = []
        var currentLine: [(text: String, box: CGRect)] = []
        var lastY: CGFloat? = nil
        let yThreshold: CGFloat = 0.015

        for frag in sorted {
            if let lastY = lastY, abs(frag.box.midY - lastY) > yThreshold {
                if !currentLine.isEmpty { lines.append(currentLine) }
                currentLine = [frag]
            } else {
                currentLine.append(frag)
            }
            lastY = frag.box.midY
        }
        if !currentLine.isEmpty { lines.append(currentLine) }
        return lines
    }

    private func isProbablyNotItem(_ text: String) -> Bool {
        // Matches date, time, or lines with lots of digits and punctuation
        let patterns = [
            #"^\d{1,2}/\d{1,2}/\d{2,4}"#, // date
            #"\d{1,2}:\d{2}"#,            // time
            #"pm|am"#,                    // am/pm
            #"us$"#,                      // ends with US
            #"^\d{2,}.*[A-Za-z]{2,}"#     // long digit string followed by letters
        ]
        for pattern in patterns {
            if let _ = text.range(of: pattern, options: .regularExpression) {
                return true
            }
        }
        return false
    }

    // Rename item by ID
    private func renameItem(id: UUID, newName: String) {
        if let idx = parsedItems.firstIndex(where: { $0.id == id }) {
            var updatedItem = parsedItems[idx]
            updatedItem.name = newName
            parsedItems[idx] = updatedItem
        }
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
