import Foundation

struct Currency: Identifiable, Codable, Equatable {
    let id: UUID
    let code: String
    let name: String
    let symbol: String
    let locale: String
    
    init(code: String, name: String, symbol: String, locale: String) {
        self.id = UUID()
        self.code = code
        self.name = name
        self.symbol = symbol
        self.locale = locale
    }
    
    static let supportedCurrencies: [Currency] = [
        Currency(code: "USD", name: "US Dollar", symbol: "$", locale: "en_US"),
        Currency(code: "EUR", name: "Euro", symbol: "€", locale: "en_EU"),
        Currency(code: "GBP", name: "British Pound", symbol: "£", locale: "en_GB"),
        Currency(code: "CAD", name: "Canadian Dollar", symbol: "C$", locale: "en_CA"),
        Currency(code: "AUD", name: "Australian Dollar", symbol: "A$", locale: "en_AU"),
        Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", locale: "ja_JP"),
        Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", locale: "zh_CN"),
        Currency(code: "INR", name: "Indian Rupee", symbol: "₹", locale: "en_IN"),
        Currency(code: "BRL", name: "Brazilian Real", symbol: "R$", locale: "pt_BR"),
        Currency(code: "MXN", name: "Mexican Peso", symbol: "$", locale: "es_MX"),
        Currency(code: "KRW", name: "South Korean Won", symbol: "₩", locale: "ko_KR"),
        Currency(code: "SGD", name: "Singapore Dollar", symbol: "S$", locale: "en_SG"),
        Currency(code: "HKD", name: "Hong Kong Dollar", symbol: "HK$", locale: "en_HK"),
        Currency(code: "CHF", name: "Swiss Franc", symbol: "CHF", locale: "de_CH"),
        Currency(code: "SEK", name: "Swedish Krona", symbol: "kr", locale: "sv_SE"),
        Currency(code: "NOK", name: "Norwegian Krone", symbol: "kr", locale: "nb_NO"),
        Currency(code: "DKK", name: "Danish Krone", symbol: "kr", locale: "da_DK"),
        Currency(code: "PLN", name: "Polish Złoty", symbol: "zł", locale: "pl_PL"),
        Currency(code: "CZK", name: "Czech Koruna", symbol: "Kč", locale: "cs_CZ"),
        Currency(code: "HUF", name: "Hungarian Forint", symbol: "Ft", locale: "hu_HU"),
        Currency(code: "RUB", name: "Russian Ruble", symbol: "₽", locale: "ru_RU"),
        Currency(code: "TRY", name: "Turkish Lira", symbol: "₺", locale: "tr_TR"),
        Currency(code: "ZAR", name: "South African Rand", symbol: "R", locale: "en_ZA"),
        Currency(code: "ILS", name: "Israeli Shekel", symbol: "₪", locale: "he_IL"),
        Currency(code: "AED", name: "UAE Dirham", symbol: "د.إ", locale: "ar_AE"),
        Currency(code: "SAR", name: "Saudi Riyal", symbol: "﷼", locale: "ar_SA"),
        Currency(code: "THB", name: "Thai Baht", symbol: "฿", locale: "th_TH"),
        Currency(code: "MYR", name: "Malaysian Ringgit", symbol: "RM", locale: "ms_MY"),
        Currency(code: "IDR", name: "Indonesian Rupiah", symbol: "Rp", locale: "id_ID"),
        Currency(code: "PHP", name: "Philippine Peso", symbol: "₱", locale: "en_PH"),
        Currency(code: "VND", name: "Vietnamese Dong", symbol: "₫", locale: "vi_VN")
    ]
    
    static let `default` = Currency(code: "USD", name: "US Dollar", symbol: "$", locale: "en_US")
}

class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: Currency = .default
    @Published var isLoadingRates = false
    @Published var lastConversionError: String?
    
    private let userDefaultsKey = "selectedCurrency"
    private let currencyService = CurrencyService.shared
    
    init() {
        loadCurrency()
        
        // Fetch real-time rates on initialization
        Task {
            await currencyService.getAllExchangeRates()
        }
    }
    
    func setCurrency(_ currency: Currency) {
        selectedCurrency = currency
        saveCurrency()
        
        // Refresh cached rates when currency changes
        Task {
            await currencyService.getAllExchangeRates()
        }
    }
    
    private func loadCurrency() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let currency = try? JSONDecoder().decode(Currency.self, from: data) {
            selectedCurrency = currency
        }
    }
    
    private func saveCurrency() {
        if let data = try? JSONEncoder().encode(selectedCurrency) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.code
        formatter.locale = Locale(identifier: selectedCurrency.locale)
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(selectedCurrency.symbol)\(String(format: "%.2f", amount))"
    }
    
    func formatAmountWithoutSymbol(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
    
    // MARK: - Currency Conversion
    
    func convertAmount(_ amount: Double, from originalCurrency: String, to targetCurrency: String) async -> Double {
        // If currencies are the same, no conversion needed
        if originalCurrency == targetCurrency {
            return amount
        }
        
        // Try to get real-time exchange rate
        if let rate = await currencyService.getExchangeRate(from: originalCurrency, to: targetCurrency) {
            return amount * rate
        }
        
        // Fallback to cached rates or static rates
        let exchangeRates = await currencyService.getAllExchangeRates()
        let fallbackRates = exchangeRates.isEmpty ? currencyService.getFallbackRates() : exchangeRates
        
        // ExchangeRate-API returns rates with USD as base currency
        if originalCurrency == "USD" {
            // Converting from USD to target currency
            if targetCurrency == "USD" {
                return amount
            } else if let rate = fallbackRates[targetCurrency] {
                return amount * rate
            } else {
                return amount // Fallback to original amount
            }
        } else {
            // Converting from non-USD currency
            if let fromRate = fallbackRates[originalCurrency] {
                // Convert to USD first: amount / fromRate
                let usdAmount = amount / fromRate
                
                if targetCurrency == "USD" {
                    return usdAmount
                } else if let toRate = fallbackRates[targetCurrency] {
                    // Convert from USD to target: usdAmount * toRate
                    return usdAmount * toRate
                } else {
                    return usdAmount // Fallback to USD amount
                }
            } else {
                return amount // Fallback to original amount
            }
        }
    }
    
    func getConvertedAmount(_ amount: Double, from originalCurrency: String) async -> Double {
        return await convertAmount(amount, from: originalCurrency, to: selectedCurrency.code)
    }
    
    func formatConvertedAmount(_ amount: Double, from originalCurrency: String) async -> String {
        let convertedAmount = await getConvertedAmount(amount, from: originalCurrency)
        return formatAmount(convertedAmount)
    }
    
    // Synchronous versions for backward compatibility (uses cached rates)
    func convertAmountSync(_ amount: Double, from originalCurrency: String, to targetCurrency: String) -> Double {
        // If currencies are the same, no conversion needed
        if originalCurrency == targetCurrency {
            return amount
        }
        
        // Use cached rates if available, otherwise fallback rates
        let exchangeRates = !currencyService.exchangeRatesCache.isEmpty ? 
            currencyService.exchangeRatesCache : 
            currencyService.getFallbackRates()
        
        // ExchangeRate-API returns rates with USD as base currency
        // So if we have USD -> EUR rate of 0.85, it means 1 USD = 0.85 EUR
        
        if originalCurrency == "USD" {
            // Converting from USD to target currency
            if targetCurrency == "USD" {
                return amount
            } else if let rate = exchangeRates[targetCurrency] {
                let result = amount * rate
                return result
            } else {
                return amount // Fallback to original amount
            }
        } else {
            // Converting from non-USD currency
            if let fromRate = exchangeRates[originalCurrency] {
                // Convert to USD first: amount / fromRate
                let usdAmount = amount / fromRate
                
                if targetCurrency == "USD" {
                    return usdAmount
                } else if let toRate = exchangeRates[targetCurrency] {
                    // Convert from USD to target: usdAmount * toRate
                    return usdAmount * toRate
                } else {
                    return usdAmount // Fallback to USD amount
                }
            } else {
                return amount // Fallback to original amount
            }
        }
    }
    
    func getConvertedAmountSync(_ amount: Double, from originalCurrency: String) -> Double {
        if !currencyService.exchangeRatesCache.isEmpty {
            return convertAmountSync(amount, from: originalCurrency, to: selectedCurrency.code)
        } else {
            Task {
                await currencyService.getAllExchangeRates()
            }
            let fallbackRates = currencyService.getFallbackRates()
            return convertAmountWithRates(amount, from: originalCurrency, to: selectedCurrency.code, rates: fallbackRates)
        }
    }
    
    func formatConvertedAmountSync(_ amount: Double, from originalCurrency: String) -> String {
        let convertedAmount = getConvertedAmountSync(amount, from: originalCurrency)
        return formatAmount(convertedAmount)
    }
    
    private func convertAmountWithRates(_ amount: Double, from originalCurrency: String, to targetCurrency: String, rates: [String: Double]) -> Double {
        if originalCurrency == targetCurrency {
            return amount
        }
        
        if originalCurrency == "USD" {
            if targetCurrency == "USD" {
                return amount
            } else if let rate = rates[targetCurrency] {
                return amount * rate
            } else {
                return amount
            }
        } else {
            if let fromRate = rates[originalCurrency] {
                let usdAmount = amount / fromRate
                
                if targetCurrency == "USD" {
                    return usdAmount
                } else if let toRate = rates[targetCurrency] {
                    return usdAmount * toRate
                } else {
                    return usdAmount
                }
            } else {
                return amount
            }
        }
    }
    
}
