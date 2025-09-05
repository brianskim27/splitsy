import SwiftUI

struct CurrencySelectionView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return Currency.supportedCurrencies
        } else {
            return Currency.supportedCurrencies.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText) ||
                currency.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search currencies...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // Currency list
                List(filteredCurrencies) { currency in
                    CurrencyRow(
                        currency: currency,
                        isSelected: currency.code == currencyManager.selectedCurrency.code
                    ) {
                        selectCurrency(currency)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func selectCurrency(_ currency: Currency) {
        currencyManager.setCurrency(currency)
        
        // Update user's preferred currency in Firebase
        Task {
            await authManager.updateUserCurrency(currency.code)
        }
        
        dismiss()
    }
}

struct CurrencyRow: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(currency.symbol)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(currency.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(currency.code)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                    
                    Text("Example: \(currency.symbol)12.34")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CurrencySelectionView()
        .environmentObject(CurrencyManager())
        .environmentObject(AuthenticationManager())
}
