import SwiftUI
import VisionKit
import Vision
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var scannedText: String
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Only allow images
        configuration.selectionLimit = 1 // Limit to one image
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImage: $selectedImage, scannedText: $scannedText)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var selectedImage: UIImage?
        @Binding var scannedText: String
        
        init(selectedImage: Binding<UIImage?>, scannedText: Binding<String>) {
            _selectedImage = selectedImage
            _scannedText = scannedText
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let result = results.first else { return }
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.selectedImage = image
                            self.performOCR(on: image) // Now accessible
                        }
                    }
                }
            }
        }

        func performOCR(on image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { (request, error) in
                if let results = request.results as? [VNRecognizedTextObservation] {
                    let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                    DispatchQueue.main.async {
                        self.scannedText = recognizedText
                    }
                }
            }
            
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error)")
            }
        }
    }
}
