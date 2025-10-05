//
//  CoffeeShopService.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import CoreLocation
import MapKit

class CoffeeShopService: NSObject, ObservableObject {
    @Published var coffeeShops: [CoffeeShop] = []
    @Published var nearbyShops: [CoffeeShop] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userLocation: CLLocation?
    @Published var selectedShop: CoffeeShop?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        setupLocationManager()
        loadCoffeeShops()
    }
    
    // MARK: - Location Management
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Location services are not enabled"
            return
        }
        
        switch locationManager.authorizationStatus {
        case .authorized, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable location access in Settings."
        @unknown default:
            break
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Coffee Shop Data
    private func loadCoffeeShops() {
        isLoading = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.coffeeShops = CoffeeShop.sampleCoffeeShops
            self.updateNearbyShops()
            self.isLoading = false
        }
    }
    
    func refreshCoffeeShops() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            // In real app, this would fetch from server
            self.coffeeShops = CoffeeShop.sampleCoffeeShops
            self.updateNearbyShops()
            self.isLoading = false
        }
    }
    
    func getCoffeeShop(by id: UUID) -> CoffeeShop? {
        return coffeeShops.first { $0.id == id }
    }
    
    // MARK: - Search and Filter
    func searchCoffeeShops(query: String) -> [CoffeeShop] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return coffeeShops
        }
        
        return coffeeShops.filter { shop in
            shop.name.localizedCaseInsensitiveContains(query) ||
            shop.address.localizedCaseInsensitiveContains(query) ||
            shop.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterCoffeeShops(by amenities: [Amenity] = [], isOpen: Bool? = nil, maxDistance: Double? = nil) -> [CoffeeShop] {
        return coffeeShops.filter { shop in
            // Filter by amenities
            if !amenities.isEmpty {
                let hasAllAmenities = amenities.allSatisfy { amenity in
                    shop.amenities.contains(amenity)
                }
                if !hasAllAmenities { return false }
            }
            
            // Filter by open status
            if let isOpen = isOpen, shop.isOpen != isOpen {
                return false
            }
            
            // Filter by distance
            if let maxDistance = maxDistance, let userLocation = userLocation {
                let shopLocation = CLLocation(latitude: shop.latitude, longitude: shop.longitude)
                let distance = userLocation.distance(from: shopLocation) / 1000 // Convert to kilometers
                if distance > maxDistance { return false }
            }
            
            return true
        }
    }
    
    // MARK: - Distance and Navigation
    func calculateDistance(to shop: CoffeeShop) -> Double? {
        guard let userLocation = userLocation else { return nil }
        let shopLocation = CLLocation(latitude: shop.latitude, longitude: shop.longitude)
        return userLocation.distance(from: shopLocation) / 1000 // Convert to kilometers
    }
    
    func getDistanceString(to shop: CoffeeShop) -> String {
        guard let distance = calculateDistance(to: shop) else { return "Distance unknown" }
        return String(format: "%.1f km", distance)
    }
    
    func openInMaps(_ shop: CoffeeShop) {
        let coordinate = CLLocationCoordinate2D(latitude: shop.latitude, longitude: shop.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = shop.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    // MARK: - Nearby Shops
    private func updateNearbyShops() {
        guard let userLocation = userLocation else {
            nearbyShops = coffeeShops
            return
        }
        
        let sortedShops = coffeeShops.compactMap { shop -> (CoffeeShop, Double)? in
            let shopLocation = CLLocation(latitude: shop.latitude, longitude: shop.longitude)
            let distance = userLocation.distance(from: shopLocation)
            return (shop, distance)
        }
        .sorted { $0.1 < $1.1 }
        .prefix(10)
        .map { $0.0 }
        
        nearbyShops = Array(sortedShops)
    }
    
    // MARK: - Favorites (Future feature)
    func toggleFavorite(_ shop: CoffeeShop) {
        // TODO: Implement favorites functionality
        // This would save to Core Data or UserDefaults
    }
    
    // MARK: - Address Geocoding
    func geocodeAddress(_ address: String) async -> CLLocationCoordinate2D? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            return placemarks.first?.location?.coordinate
        } catch {
            await MainActor.run {
                errorMessage = "Failed to geocode address: \(error.localizedDescription)"
            }
            return nil
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CoffeeShopService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        updateNearbyShops()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorized, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied"
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Map Annotations
extension CoffeeShop {
    var annotation: CoffeeShopAnnotation {
        CoffeeShopAnnotation(
            coordinate: coordinate,
            title: name,
            subtitle: address,
            coffeeShop: self
        )
    }
}

class CoffeeShopAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let coffeeShop: CoffeeShop
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, coffeeShop: CoffeeShop) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.coffeeShop = coffeeShop
        super.init()
    }
}