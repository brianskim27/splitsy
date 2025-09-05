# Real-Time Currency Conversion Setup

## Overview
The app now supports real-time currency conversion using the ExchangeRate-API. This provides accurate, up-to-date exchange rates for all supported currencies.

## Setup Instructions

### 1. Get Your Free API Key
1. Visit [ExchangeRate-API](https://www.exchangerate-api.com/)
2. Sign up for a free account
3. Get your API key from the dashboard

### 2. Configure the API Key
1. Open `splitsy/CurrencyService.swift`
2. Find the line: `private let apiKey = "YOUR_API_KEY_HERE"`
3. Replace `"YOUR_API_KEY_HERE"` with your actual API key

### 3. API Limits (Free Tier)
- **1,500 requests per month**
- **No credit card required**
- **Real-time rates updated daily**

## Features

### ✅ Real-Time Conversion
- Fetches live exchange rates from the API
- Automatically converts amounts when viewing splits in different currencies
- Shows loading indicators while fetching rates

### ✅ Smart Caching
- Caches exchange rates for 1 hour to reduce API calls
- Falls back to cached rates if API is unavailable
- Uses static fallback rates as last resort

### ✅ Error Handling
- Graceful fallback to cached or static rates
- User-friendly error messages
- No app crashes if API is down

### ✅ Loading States
- Shows "Converting..." indicator while fetching rates
- Smooth user experience with async loading

## How It Works

1. **First Load**: App fetches real-time rates from API
2. **Caching**: Rates are cached for 1 hour to reduce API usage
3. **Fallback**: If API fails, uses cached rates or static fallback rates
4. **Conversion**: All amounts are converted to user's selected currency

## Supported Currencies
All 30+ currencies supported by the app now use real-time conversion:
- USD, EUR, GBP, CAD, AUD, JPY, CNY, INR, BRL, MXN
- KRW, SGD, HKD, CHF, SEK, NOK, DKK, PLN, CZK, HUF
- RUB, TRY, ZAR, ILS, AED, SAR, THB, MYR, IDR, PHP, VND

## Testing
1. Set your currency to EUR in settings
2. View a split that was created in USD
3. You should see the amounts convert to EUR with real-time rates
4. A loading indicator will show while fetching rates

## Troubleshooting
- **No conversion happening**: Check your API key is correctly set
- **Loading forever**: Check internet connection
- **Wrong rates**: API rates update daily, may take time to reflect
- **App crashes**: Falls back to static rates automatically
