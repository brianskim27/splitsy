import Foundation
import Combine

// MARK: - Currency API Response Models
struct ExchangeRateResponse: Codable {
    let result: String
    let documentation: String
    let termsOfUse: String
    let timeLastUpdateUnix: Int
    let timeLastUpdateUtc: String
    let timeNextUpdateUnix: Int
    let timeNextUpdateUtc: String
    let baseCode: String
    let targetCode: String
    let conversionRate: Double
    
    enum CodingKeys: String, CodingKey {
        case result, documentation
        case termsOfUse = "terms_of_use"
        case timeLastUpdateUnix = "time_last_update_unix"
        case timeLastUpdateUtc = "time_last_update_utc"
        case timeNextUpdateUnix = "time_next_update_unix"
        case timeNextUpdateUtc = "time_next_update_utc"
        case baseCode = "base_code"
        case targetCode = "target_code"
        case conversionRate = "conversion_rate"
    }
}

struct ExchangeRatesResponse: Codable {
    let result: String
    let documentation: String
    let termsOfUse: String
    let timeLastUpdateUnix: Int
    let timeLastUpdateUtc: String
    let timeNextUpdateUnix: Int
    let timeNextUpdateUtc: String
    let baseCode: String
    let conversionRates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case result, documentation
        case termsOfUse = "terms_of_use"
        case timeLastUpdateUnix = "time_last_update_unix"
        case timeLastUpdateUtc = "time_last_update_utc"
        case timeNextUpdateUnix = "time_next_update_unix"
        case timeNextUpdateUtc = "time_next_update_utc"
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
    }
}

// MARK: - Currency Service
class CurrencyService: ObservableObject {
    static let shared = CurrencyService()
    
    private let baseURL = "https://v6.exchangerate-api.com/v6"
    private let apiKey = "d8696d63c2d5eaeb9e3b2b51"
    private let session = URLSession.shared
    
    // Cache for exchange rates
    var exchangeRatesCache: [String: Double] = [:]
    private var lastCacheUpdate: Date?
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    
    // Published properties for UI updates
    @Published var isLoading = false
    @Published var lastError: String?
    
    private init() {
        // Load cached rates on initialization
        loadCachedRates()
    }
    
    // MARK: - Public Methods
    
    func getExchangeRate(from: String, to: String) async -> Double? {
        // If same currency, return 1.0
        if from == to {
            return 1.0
        }
        
        // Check cache first
        let cacheKey = "\(from)_\(to)"
        if let cachedRate = exchangeRatesCache[cacheKey],
           let lastUpdate = lastCacheUpdate,
           Date().timeIntervalSince(lastUpdate) < cacheValidityDuration {
            return cachedRate
        }
        
        // Fetch from API
        return await fetchExchangeRate(from: from, to: to)
    }
    
    func getAllExchangeRates(baseCurrency: String = "USD") async -> [String: Double] {
        // Check cache first
        if let lastUpdate = lastCacheUpdate,
           Date().timeIntervalSince(lastUpdate) < cacheValidityDuration,
           !exchangeRatesCache.isEmpty {
            return exchangeRatesCache
        }
        
        // Fetch from API
        return await fetchAllExchangeRates(baseCurrency: baseCurrency)
    }
    
    // MARK: - Private Methods
    
    private func fetchExchangeRate(from: String, to: String) async -> Double? {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let urlString = "\(baseURL)/\(apiKey)/pair/\(from)/\(to)"
        
        guard let url = URL(string: urlString) else {
            await MainActor.run { lastError = "Invalid URL" }
            return nil
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            // Cache the result
            let cacheKey = "\(from)_\(to)"
            exchangeRatesCache[cacheKey] = response.conversionRate
            lastCacheUpdate = Date()
            saveCachedRates()
            
            await MainActor.run { lastError = nil }
            return response.conversionRate
            
        } catch {
            await MainActor.run { lastError = "Failed to fetch exchange rate: \(error.localizedDescription)" }
            print("Error fetching exchange rate: \(error)")
            return nil
        }
    }
    
    private func fetchAllExchangeRates(baseCurrency: String = "USD") async -> [String: Double] {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let urlString = "\(baseURL)/\(apiKey)/latest/\(baseCurrency)"
        
        guard let url = URL(string: urlString) else {
            await MainActor.run { lastError = "Invalid URL" }
            return [:]
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            
            let response = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
            
            exchangeRatesCache = response.conversionRates
            lastCacheUpdate = Date()
            
            await MainActor.run { lastError = nil }
            return response.conversionRates
            
        } catch {
            await MainActor.run { lastError = "Failed to fetch exchange rates: \(error.localizedDescription)" }
            return [:]
        }
    }
    
    // MARK: - Cache Management
    
    private func loadCachedRates() {
        if let timestamp = UserDefaults.standard.object(forKey: "lastCacheUpdate") as? Date {
            lastCacheUpdate = timestamp
        }
    }
    
    private func saveCachedRates() {
        if let timestamp = lastCacheUpdate {
            UserDefaults.standard.set(timestamp, forKey: "lastCacheUpdate")
        }
    }
    
    // MARK: - Fallback Rates
    
    func getFallbackRates() -> [String: Double] {
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
