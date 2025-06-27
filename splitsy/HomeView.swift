import SwiftUI
import MapKit
import CoreLocation

struct HomeView: View {
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Text("Hi, Brian!")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)

            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                    Text("Add Receipt")
                        .font(.title2)
                        .bold()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(16)
                .shadow(radius: 4)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Splits")
                    .font(.headline)
                    .padding(.horizontal)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 80)
                    .overlay(Text("No recent splits yet.").foregroundColor(.gray))
                    .padding(.horizontal)
            }
            Spacer()
        }
        .padding(.top, 40)
    }
}

// Store Model with Distance Calculation
struct Store: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
    var isFavorited: Bool

    func distance(from location: CLLocation) -> Double {
        let storeLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: storeLocation) / 1609.34 // Convert to miles
    }
}
