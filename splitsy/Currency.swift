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
    
    private let userDefaultsKey = "selectedCurrency"
    
    init() {
        loadCurrency()
    }
    
    func setCurrency(_ currency: Currency) {
        selectedCurrency = currency
        saveCurrency()
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
    
    func convertAmount(_ amount: Double, from originalCurrency: String, to targetCurrency: String) -> Double {
        // If currencies are the same, no conversion needed
        if originalCurrency == targetCurrency {
            return amount
        }
        
        // Get exchange rates (simplified - in a real app, you'd fetch from an API)
        let exchangeRates = getExchangeRates()
        
        // Convert to USD first (base currency)
        let usdAmount: Double
        if originalCurrency == "USD" {
            usdAmount = amount
        } else if let rate = exchangeRates[originalCurrency] {
            usdAmount = amount / rate
        } else {
            // If we don't have the exchange rate, return original amount
            return amount
        }
        
        // Convert from USD to target currency
        if targetCurrency == "USD" {
            return usdAmount
        } else if let rate = exchangeRates[targetCurrency] {
            return usdAmount * rate
        } else {
            // If we don't have the exchange rate, return USD amount
            return usdAmount
        }
    }
    
    func getConvertedAmount(_ amount: Double, from originalCurrency: String) -> Double {
        return convertAmount(amount, from: originalCurrency, to: selectedCurrency.code)
    }
    
    func formatConvertedAmount(_ amount: Double, from originalCurrency: String) -> String {
        let convertedAmount = getConvertedAmount(amount, from: originalCurrency)
        return formatAmount(convertedAmount)
    }
    
    private func getExchangeRates() -> [String: Double] {
        // Simplified exchange rates (in a real app, fetch from an API like Fixer.io or ExchangeRate-API)
        return [
            "EUR": 0.85,
            "GBP": 0.73,
            "CAD": 1.35,
            "AUD": 1.52,
            "JPY": 110.0,
            "CNY": 6.45,
            "INR": 74.0,
            "BRL": 5.2,
            "MXN": 20.0,
            "KRW": 1180.0,
            "SGD": 1.35,
            "HKD": 7.8,
            "CHF": 0.92,
            "SEK": 8.5,
            "NOK": 8.8,
            "DKK": 6.3,
            "PLN": 3.9,
            "CZK": 21.5,
            "HUF": 300.0,
            "RUB": 75.0,
            "TRY": 8.5,
            "ZAR": 14.5,
            "ILS": 3.2,
            "AED": 3.67,
            "SAR": 3.75,
            "THB": 33.0,
            "MYR": 4.2,
            "IDR": 14300.0,
            "PHP": 50.0,
            "VND": 23000.0
        ]
    }
}
