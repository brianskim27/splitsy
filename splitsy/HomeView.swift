import SwiftUI
import MapKit
import CoreLocation

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedFilter: String = "All"
    @State private var selectedDistance: Double = 5.0 // Default: 5 miles
    @State private var userLocation: CLLocation? = nil
    @State private var stores: [Store] = []
    
    let filters = ["All", "Restaurants", "Cafes", "Grocery Stores"]
    let distanceOptions: [Double] = [1, 5, 10, 25] // Miles filter

    var filteredStores: [Store] {
        stores
            .filter { store in
                (selectedFilter == "All" || store.type == selectedFilter) &&
                (searchText.isEmpty || store.name.lowercased().contains(searchText.lowercased())) &&
                (userLocation != nil ? store.distance(from: userLocation!) <= selectedDistance : true)
            }
            .sorted { $0.distance(from: userLocation!) < $1.distance(from: userLocation!) }
    }

    var body: some View {
        NavigationView {
            VStack {
                // 🔍 Search Bar
                TextField("Search stores...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // 📍 Distance Filter
                Picker("Distance", selection: $selectedDistance) {
                    ForEach(distanceOptions, id: \.self) { distance in
                        Text("\(Int(distance)) miles").tag(distance)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // 🏷️ Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(filters, id: \.self) { filter in
                            Text(filter)
                                .padding()
                                .background(selectedFilter == filter ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedFilter = filter
                                    fetchNearbyStores()
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 📍 Store List
                List(filteredStores) { store in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(store.name)
                                .font(.headline)
                            if let location = userLocation {
                                Text(String(format: "%.1f miles away", store.distance(from: location)))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Button(action: { toggleFavorite(for: store) }) {
                            Image(systemName: store.isFavorited ? "heart.fill" : "heart")
                                .foregroundColor(store.isFavorited ? .red : .gray)
                        }
                    }
                }
            }
            .navigationTitle("Nearby Stores")
            .onAppear {
                fetchUserLocation()
            }
        }
    }
    
    private func toggleFavorite(for store: Store) {
        if let index = stores.firstIndex(where: { $0.id == store.id }) {
            stores[index].isFavorited.toggle()
        }
    }

    private func fetchUserLocation() {
        LocationManager.shared.requestLocation { location in
            self.userLocation = location
            fetchNearbyStores()
        }
    }

    private func fetchNearbyStores() {
        guard let location = userLocation else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = selectedFilter == "All" ? "store" : selectedFilter
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: selectedDistance * 1609.34, // Convert miles to meters
            longitudinalMeters: selectedDistance * 1609.34
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.stores = response.mapItems.map { item in
                        Store(
                            name: item.name ?? "Unknown",
                            type: selectedFilter,
                            latitude: item.placemark.coordinate.latitude,
                            longitude: item.placemark.coordinate.longitude,
                            isFavorited: false
                        )
                    }
                }
            }
        }
    }
}

// 📍 Store Model with Distance Calculation
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
