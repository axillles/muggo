//
//  NearbyShopsView.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import SwiftUI
import MapKit

struct NearbyShopsView: View {
    @EnvironmentObject var coffeeShopService: CoffeeShopService
    @EnvironmentObject var cartManager: CartManager
    
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedSortOption = SortOption.distance
    @State private var selectedAmenities: Set<Amenity> = []
    @State private var showOnlyOpen = false
    @State private var maxDistance: Double = 10.0 // km
    @State private var selectedShop: CoffeeShop?
    @State private var showingShopDetail = false
    
    enum SortOption: String, CaseIterable {
        case distance = "Distance"
        case rating = "Rating"
        case name = "Name"
        case reviewCount = "Reviews"
    }
    
    var filteredAndSortedShops: [CoffeeShop] {
        var shops = coffeeShopService.coffeeShops
        
        // Apply search filter
        if !searchText.isEmpty {
            shops = coffeeShopService.searchCoffeeShops(query: searchText)
        }
        
        // Apply filters
        shops = coffeeShopService.filterCoffeeShops(
            by: Array(selectedAmenities),
            isOpen: showOnlyOpen ? true : nil,
            maxDistance: maxDistance
        )
        
        // Apply sorting
        switch selectedSortOption {
        case .distance:
            shops = shops.sorted { shop1, shop2 in
                guard let distance1 = coffeeShopService.calculateDistance(to: shop1),
                      let distance2 = coffeeShopService.calculateDistance(to: shop2) else {
                    return false
                }
                return distance1 < distance2
            }
        case .rating:
            shops = shops.sorted { $0.rating > $1.rating }
        case .name:
            shops = shops.sorted { $0.name < $1.name }
        case .reviewCount:
            shops = shops.sorted { $0.reviewCount > $1.reviewCount }
        }
        
        return shops
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search coffee shops...")
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Sort and Filter Options
                HStack {
                    // Sort Picker
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedSortOption = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if selectedSortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Sort: \(selectedSortOption.rawValue)")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                    
                    // Filter Button
                    Button(action: {
                        showingFilters = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Filters")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(hasActiveFilters ? Color.brown.opacity(0.2) : Color(.systemGray5))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Results Count
                    Text("\(filteredAndSortedShops.count) shops")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Coffee Shops List
                List(filteredAndSortedShops) { shop in
                    CoffeeShopRowView(shop: shop) {
                        selectedShop = shop
                        showingShopDetail = true
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await coffeeShopService.refreshCoffeeShops()
                }
            }
            .navigationTitle("Nearby Coffee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coffeeShopService.startLocationUpdates()
                    }) {
                        Image(systemName: "location.circle")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    selectedAmenities: $selectedAmenities,
                    showOnlyOpen: $showOnlyOpen,
                    maxDistance: $maxDistance
                )
            }
            .sheet(isPresented: $showingShopDetail) {
                if let shop = selectedShop {
                    CoffeeShopDetailView(shop: shop)
                }
            }
            .onAppear {
                coffeeShopService.startLocationUpdates()
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        !selectedAmenities.isEmpty || showOnlyOpen || maxDistance < 10.0
    }
}

struct CoffeeShopRowView: View {
    let shop: CoffeeShop
    let onTap: () -> Void
    @EnvironmentObject var coffeeShopService: CoffeeShopService
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Shop Image Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brown.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.brown)
                }
                
                // Shop Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(shop.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Open/Closed Status
                        Text(shop.isOpen ? "Open" : "Closed")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(shop.isOpen ? Color.green : Color.red)
                            .cornerRadius(4)
                    }
                    
                    Text(shop.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        // Rating
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", shop.rating))
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("(\(shop.reviewCount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Distance
                        if let distance = coffeeShopService.calculateDistance(to: shop) {
                            HStack(spacing: 2) {
                                Image(systemName: "location")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(String(format: "%.1f km", distance))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Top Amenities (first 3)
                    if !shop.amenities.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(Array(shop.amenities.prefix(3)), id: \.self) { amenity in
                                Image(systemName: amenity.icon)
                                    .font(.caption)
                                    .foregroundColor(.brown)
                            }
                            
                            if shop.amenities.count > 3 {
                                Text("+\(shop.amenities.count - 3)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // Navigation Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterView: View {
    @Binding var selectedAmenities: Set<Amenity>
    @Binding var showOnlyOpen: Bool
    @Binding var maxDistance: Double
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Status") {
                    Toggle("Show only open shops", isOn: $showOnlyOpen)
                }
                
                Section("Distance") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Maximum distance: \(String(format: "%.1f", maxDistance)) km")
                            .font(.subheadline)
                        
                        Slider(value: $maxDistance, in: 0.5...20.0, step: 0.5) {
                            Text("Distance")
                        } minimumValueLabel: {
                            Text("0.5")
                                .font(.caption)
                        } maximumValueLabel: {
                            Text("20")
                                .font(.caption)
                        }
                    }
                }
                
                Section("Amenities") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(Amenity.allCases, id: \.self) { amenity in
                            Button(action: {
                                if selectedAmenities.contains(amenity) {
                                    selectedAmenities.remove(amenity)
                                } else {
                                    selectedAmenities.insert(amenity)
                                }
                            }) {
                                HStack {
                                    Image(systemName: amenity.icon)
                                    Text(amenity.rawValue)
                                        .font(.caption)
                                    Spacer()
                                    if selectedAmenities.contains(amenity) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(selectedAmenities.contains(amenity) ? Color.brown.opacity(0.1) : Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedAmenities.removeAll()
                        showOnlyOpen = false
                        maxDistance = 10.0
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    NearbyShopsView()
        .environmentObject(CoffeeShopService())
        .environmentObject(CartManager())
}