import SwiftUI
import VisionKit
import Vision
import PhotosUI

struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedText: $scannedText)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var scannedText: String

        init(scannedText: Binding<String>) {
            _scannedText = scannedText
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)

            guard scan.pageCount > 0 else { return }
            let image = scan.imageOfPage(at: 0)
            print("Scanned Image: \(image)")  // Log the scanned image
            
            // Apply image preprocessing before performing OCR
            let processedImage = preprocessImage(for: image)
            print("Processed Image: \(processedImage)")  // Check if image processing is working correctly

            // Perform OCR on the processed image
            if let text = performOCR(on: processedImage) {
                scannedText = text
            }
        }
    }
}

extension DocumentScannerView.Coordinator {

    // MARK: - Image Preprocessing
    private func preprocessImage(for ocr: UIImage) -> UIImage {
        let ciImage = CIImage(image: ocr)!
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(1.5, forKey: kCIInputContrastKey) // Improve contrast for better OCR
        let filteredImage = filter.outputImage!
        
        // Convert image to grayscale for better OCR performance
        let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono")!
        grayscaleFilter.setValue(filteredImage, forKey: kCIInputImageKey)
        let grayscaleImage = grayscaleFilter.outputImage!
        
        return UIImage(ciImage: grayscaleImage)
    }
    
    // MARK: - Perform OCR
    private func performOCR(on image: UIImage) -> String? {
        print("Performing OCR...")  // Add this line to check if the method is triggered
        guard let cgImage = image.cgImage else { return nil }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let results = request.results as? [VNRecognizedTextObservation] {
                print("OCR Results: \(results)")  // Log the OCR results

                let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                
                // Now, extract items and prices from the OCR text
                let (items, prices) = self.extractReceiptData(from: recognizedText)
                
                // Update the display with parsed items and prices
                self.updateReceiptDisplay(items: items, prices: prices)

                // Update scannedText to display in the UI if necessary
                DispatchQueue.main.async {
                    self.scannedText = recognizedText
                }
            }
        }

        // Setting the recognition level to .accurate for better accuracy
        request.recognitionLevel = .accurate

        do {
            try handler.perform([request])
            return scannedText
        } catch {
            print("Failed to perform OCR: \(error)")
            return nil
        }
    }


    // MARK: - Extract Data from OCR Text (Receipt Parsing)
    private func extractReceiptData(from text: String) -> (items: [String], prices: [String]) {
        var items: [String] = []
        var prices: [String] = []

        // Split the text into lines
        let lines = text.split(separator: "\n")

        // Regular expression to match prices (with or without $ sign)
        let priceRegex = try! NSRegularExpression(pattern: "(\\$?\\d+\\.\\d{2})", options: [])

        // Loop through each line and try to find prices and corresponding items
        for line in lines {
            let lineText = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Debug log: Check the raw line text
            print("Line: \(lineText)")
            
            // If a price is found, try to extract the item as well
            if let priceMatch = priceRegex.firstMatch(in: lineText, options: [], range: NSRange(lineText.startIndex..., in: lineText)) {
                var price = (lineText as NSString).substring(with: priceMatch.range)
                
                // Debug log: Check the extracted price
                print("Extracted Price: \(price)")
                
                // If no dollar sign is found, prepend one
                if !price.hasPrefix("$") {
                    price = "$" + price
                }
                
                // Debug log: Check the formatted price
                print("Formatted Price: \(price)")
                
                prices.append(price)

                // Extract the item: everything before the price
                let itemStartIndex = lineText.index(lineText.startIndex, offsetBy: priceMatch.range.location)
                let item = String(lineText[..<itemStartIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Debug log: Check the extracted item
                print("Extracted Item: \(item)")
                
                items.append(item)
            }
        }
        
        // Debug log: Final items and prices arrays
        print("Items: \(items)")
        print("Prices: \(prices)")
        
        return (items, prices)
    }

    // MARK: - Update Display with Parsed Receipt Data
    private func updateReceiptDisplay(items: [String], prices: [String]) {
        var formattedText = ""
        
        // Loop through the items and display them with prices in the same line
        for (index, item) in items.enumerated() {
            let price = index < prices.count ? prices[index] : "$0.00"
            formattedText += "\(item) - \(price)\n"  // Print item and price on the same line
        }
        
        self.scannedText = formattedText
    }
}

// Need to fix
