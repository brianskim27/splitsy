import SwiftUI
import Vision
import PhotosUI

struct ReceiptInputView: View {
    @Binding var receiptImage: UIImage?
    @Binding var parsedItems: [ReceiptItem]
    var onNext: (([ReceiptItem]) -> Void)? = nil
    @EnvironmentObject var currencyManager: CurrencyManager
    @State private var detectedTexts: [(id: UUID, text: String, box: CGRect)] = [] // Detected texts with unique IDs
    @State private var isPickerPresented = false // Open picker at start
    @State private var isNavigatingToAssignmentView = false // Tracks navigation
    @State private var isCameraPresented = false // Add state for camera
    @State private var showFullScreenImage = false
    @State private var editingItemId: UUID? = nil
    @State private var editingItemName: String = ""
    @State private var editingItemPrice: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var showAddItem = false
    @State private var newItemName: String = ""
    @State private var newItemPrice: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Receipt Image Display
                ZStack {
                    if let receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .onTapGesture { showFullScreenImage = true }
                            .accessibilityLabel("Tap to enlarge receipt image")
                            .sheet(isPresented: $showFullScreenImage) {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    VStack {
                                        Spacer()
                                        ZoomableImageView(image: receiptImage)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        Spacer()
                                        Button("Close") { showFullScreenImage = false }
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                            }
                    } else {
                        Color.secondary.opacity(0.08)
                            .frame(height: 300)
                            .cornerRadius(20)
                            .overlay(
                                VStack(spacing: 24) {
                                    Text("Analyze")
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
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()

                // Items Wheel at Bottom
                if !parsedItems.isEmpty {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Items")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(parsedItems.count) item\(parsedItems.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        
                        // Horizontal Scrollable Items
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(parsedItems, id: \.id) { item in
                                    VStack(spacing: 12) {
                                        // Item Card
                                        VStack(spacing: 8) {
                                            if editingItemId == item.id {
                                                // Editing Mode
                                                VStack(spacing: 6) {
                                                    TextField("Item Name", text: $editingItemName, onCommit: {
                                                        saveItemEdits(id: item.id)
                                                    })
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .font(.caption)
                                                    .multilineTextAlignment(.center)
                                                    
                                                    HStack(spacing: 2) {
                                                        Text(currencyManager.selectedCurrency.symbol)
                                                            .foregroundColor(.green)
                                                            .font(.caption)
                                                            .fontWeight(.medium)
                                                        TextField("0.00", text: $editingItemPrice, onCommit: {
                                                            saveItemEdits(id: item.id)
                                                        })
                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                        .keyboardType(.decimalPad)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .multilineTextAlignment(.center)
                                                    }
                                                }
                                            } else {
                                                // Display Mode
                                                VStack(spacing: 6) {
                                                    Text(item.name)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.primary)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.center)
                                                        .frame(height: 32)
                                                    
                                                    Text(currencyManager.formatAmount(item.cost))
                                                        .font(.title3)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                        .frame(width: 120, height: 80)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6).opacity(0.6))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(.systemGray4), lineWidth: 1)
                                        )
                                        
                                        // Action Buttons - Always visible
                                        HStack(spacing: 8) {
                                            if editingItemId == item.id {
                                                // Save and Cancel buttons when editing
                                                Button(action: {
                                                    saveItemEdits(id: item.id)
                                                }) {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.green)
                                                        .frame(width: 24, height: 24)
                                                        .background(Color.green.opacity(0.15))
                                                        .clipShape(Circle())
                                                }
                                                
                                                Button(action: {
                                                    editingItemId = nil
                                                    editingItemName = ""
                                                    editingItemPrice = ""
                                                }) {
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.red)
                                                        .frame(width: 24, height: 24)
                                                        .background(Color.red.opacity(0.15))
                                                        .clipShape(Circle())
                                                }
                                            } else {
                                                // Edit and Delete buttons when not editing
                                                Button(action: {
                                                    editingItemId = item.id
                                                    editingItemName = item.name
                                                    editingItemPrice = String(format: "%.2f", item.cost)
                                                }) {
                                                    Image(systemName: "pencil")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.blue)
                                                        .frame(width: 24, height: 24)
                                                        .background(Color.blue.opacity(0.15))
                                                        .clipShape(Circle())
                                                }
                                                
                                                Button(action: { removeItemById(item.id) }) {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.red)
                                                        .frame(width: 24, height: 24)
                                                        .background(Color.red.opacity(0.15))
                                                        .clipShape(Circle())
                                                }
                                                .accessibilityLabel("Delete item")
                                            }
                                        }
                                    }
                                }
                                
                                // Add Item Button
                                if showAddItem {
                                    AddItemCard(
                                        newItemName: $newItemName,
                                        newItemPrice: $newItemPrice,
                                        onSave: addNewItem,
                                        onCancel: {
                                            showAddItem = false
                                            newItemName = ""
                                            newItemPrice = ""
                                        }
                                    )
                                } else {
                                    // Add (+) Button
                                    VStack(spacing: 12) {
                                        // Item Card
                                        Button(action: {
                                            showAddItem = true
                                            newItemName = ""
                                            newItemPrice = ""
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.blue)
                                                    .padding(.top, 6)
                                                
                                                Text("Add Item")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.blue)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                                    .frame(height: 32)
                                            }
                                        }
                                        .frame(width: 120, height: 80)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                        )
                                        .accessibilityLabel("Add new item manually")
                                        
                                        // Action Buttons - Invisible to match other items' spacing
                                        HStack(spacing: 8) {
                                            // Invisible buttons to match the height of edit/delete buttons
                                            Color.clear
                                                .frame(width: 24, height: 24)
                                            Color.clear
                                                .frame(width: 24, height: 24)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }

                Spacer()
                    .frame(height: max(0, keyboardHeight > 0 ? 20 : 0))

                // Next Button
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
                    Text("Analyze")
                        .font(.title2)
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
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping anywhere
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
        .onAppear {
            if let image = receiptImage, parsedItems.isEmpty {
                analyzeReceiptImage(image)
            }
            
            // Keyboard observers
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            // Remove keyboard observers
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        .onChange(of: receiptImage) { oldValue, newValue in
            if let image = newValue, newValue != oldValue {
                parsedItems.removeAll()
                analyzeReceiptImage(image)
            }
        }
        .padding(.bottom, keyboardHeight)
        .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
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
            if error != nil {
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
            }
        }
    }

    // Group Items & Prices from OCR Data
    private func groupItemsAndPrices(detectedTexts: [(text: String, box: CGRect)]) -> [ReceiptItem] {
        let allText = detectedTexts.map { $0.text }.joined(separator: " ").lowercased()
        if allText.contains("walmart") {
            return parseWalmartReceipt(detectedTexts)
        } else if allText.contains("bj's") || allText.contains("bjs") {
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
                // Remove common currency symbols
                let cleanedPrice = priceText.replacingOccurrences(of: "$", with: "")
                    .replacingOccurrences(of: "€", with: "")
                    .replacingOccurrences(of: "£", with: "")
                    .replacingOccurrences(of: "¥", with: "")
                    .replacingOccurrences(of: "₹", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                if let priceValue = Double(cleanedPrice) {
                    priceCandidates.append((text: currencyManager.formatAmount(priceValue), box: detectedText.box))
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

    // Save item edits (name and price) by ID
    private func saveItemEdits(id: UUID) {
        if let idx = parsedItems.firstIndex(where: { $0.id == id }) {
            var updatedItem = parsedItems[idx]
            
            // Update name
            let trimmedName = editingItemName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedName.isEmpty {
                updatedItem.name = trimmedName
            }
            
            // Update price
            if let price = Double(editingItemPrice) {
                updatedItem.cost = price
            }
            
            parsedItems[idx] = updatedItem
            editingItemId = nil
            editingItemName = ""
            editingItemPrice = ""
        }
    }
    
    // MARK: - Add New Item Function
    private func addNewItem() {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let price = Double(newItemPrice.trimmingCharacters(in: .whitespacesAndNewlines)),
              price > 0 else {
            return
        }
        
        let newItem = ReceiptItem(
            name: newItemName.trimmingCharacters(in: .whitespacesAndNewlines),
            cost: price
        )
        
        parsedItems.append(newItem)
        
        // Reset the form
        showAddItem = false
        newItemName = ""
        newItemPrice = ""
    }
}

// MARK: - AddItemCard Component
struct AddItemCard: View {
    @Binding var newItemName: String
    @Binding var newItemPrice: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @EnvironmentObject var currencyManager: CurrencyManager
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isPriceFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Item Input Card
            VStack(spacing: 8) {
                VStack(spacing: 6) {
                    TextField("Item Name", text: $newItemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .focused($isNameFieldFocused)
                        .onSubmit {
                            isPriceFieldFocused = true
                        }
                    
                    HStack(spacing: 2) {
                        Text(currencyManager.selectedCurrency.symbol)
                            .foregroundColor(.green)
                            .font(.caption)
                            .fontWeight(.medium)
                        TextField("0.00", text: $newItemPrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.caption)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .focused($isPriceFieldFocused)
                            .onSubmit {
                                if !newItemName.isEmpty && !newItemPrice.isEmpty {
                                    onSave()
                                }
                            }
                    }
                }
            }
            .frame(width: 120, height: 80)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6).opacity(0.6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            )
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: onSave) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                        .frame(width: 24, height: 24)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Circle())
                }
                .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                         newItemPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity((newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                         newItemPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1.0)
                
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                        .background(Color.red.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            isNameFieldFocused = true
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
