import SwiftUI
import VisionKit
import Vision
import PhotosUI

struct ReceiptScannerView: View {
    @State private var isPresentingScanner = false
    @State private var isPresentingPhotoPicker = false
    @State private var scannedText: String = "No text scanned yet."
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            // Use ScrollView to allow scrolling
            ScrollView {
                Text(scannedText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding()
                    .lineLimit(nil) // Allow multiple lines without truncation
            }
            .frame(maxHeight: .infinity) // Allow it to expand and scroll

            HStack {
                Button("Scan Receipt") {
                    isPresentingScanner = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Pick from Library") {
                    isPresentingPhotoPicker = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .navigationTitle("Scan Receipt")
        .sheet(isPresented: $isPresentingScanner) {
            DocumentScannerView(scannedText: $scannedText)
        }
        .sheet(isPresented: $isPresentingPhotoPicker) {
            PhotoPicker(selectedImage: $selectedImage, scannedText: $scannedText)
        }
    }
}
