import SwiftUI

// MARK: - Currency Conversion View
struct CurrencyConversionView: View {
    let amount: Double
    let fromCurrency: String
    @EnvironmentObject var currencyManager: CurrencyManager
    
    @State private var convertedAmount: Double?
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        Group {
            if isLoading {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Converting...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if let error = error {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            } else if let convertedAmount = convertedAmount {
                Text(currencyManager.formatAmount(convertedAmount))
            } else {
                Text(currencyManager.formatAmount(amount))
            }
        }
        .onAppear {
            loadConversion()
        }
        .onChange(of: currencyManager.selectedCurrency) {
            loadConversion()
        }
    }
    
    private func loadConversion() {
        guard fromCurrency != currencyManager.selectedCurrency.code else {
            convertedAmount = amount
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            let converted = await currencyManager.getConvertedAmount(amount, from: fromCurrency)
            await MainActor.run {
                convertedAmount = converted
                isLoading = false
            }
        }
    }
}

// MARK: - Async Currency Text
struct AsyncCurrencyText: View {
    let amount: Double
    let fromCurrency: String
    let font: Font
    let foregroundColor: Color
    
    @EnvironmentObject var currencyManager: CurrencyManager
    
    @State private var convertedAmount: Double?
    @State private var isLoading = false
    @State private var error: String?
    
    init(amount: Double, fromCurrency: String, font: Font = .body, foregroundColor: Color = .primary) {
        self.amount = amount
        self.fromCurrency = fromCurrency
        self.font = font
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        Group {
            if isLoading {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("...")
                        .font(font)
                        .foregroundColor(foregroundColor)
                }
            } else if error != nil {
                Text("Error")
                    .font(font)
                    .foregroundColor(.red)
            } else if let convertedAmount = convertedAmount {
                Text(currencyManager.formatAmount(convertedAmount))
                    .font(font)
                    .foregroundColor(foregroundColor)
            } else {
                Text(currencyManager.formatAmount(amount))
                    .font(font)
                    .foregroundColor(foregroundColor)
            }
        }
        .onAppear {
            loadConversion()
        }
        .onChange(of: currencyManager.selectedCurrency) {
            loadConversion()
        }
    }
    
    private func loadConversion() {
        guard fromCurrency != currencyManager.selectedCurrency.code else {
            convertedAmount = amount
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            let converted = await currencyManager.getConvertedAmount(amount, from: fromCurrency)
            await MainActor.run {
                convertedAmount = converted
                isLoading = false
            }
        }
    }
}
