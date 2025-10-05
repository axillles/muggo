import SwiftUI
import MapKit

struct CoffeeShopDetailView: View {
    let shop: CoffeeShop
    @StateObject private var cartManager = CartManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMenuCategory: String = "All"
    @State private var showingDirections = false
    @State private var showingCallSheet = false
    
    private var menuCategories: [String] {
        let categories = Set(shop.menu.map { $0.category.rawValue })
        return ["All"] + Array(categories).sorted()
    }
    
    private var filteredMenu: [MenuItem] {
        if selectedMenuCategory == "All" {
            return shop.menu
        } else {
            return shop.menu.filter { $0.category.rawValue == selectedMenuCategory }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Image and Basic Info
                    headerSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Shop Information
                    shopInfoSection
                    
                    // Hours Section
                    hoursSection
                    
                    // Menu Section
                    menuSection
                    
                    Spacer(minLength: 100) // Space for cart button
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleFavorite) {
                        Image(systemName: "heart")
                            .foregroundColor(.gray)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if cartManager.cart.itemCount > 0 {
                    cartOverlay
                }
            }
        }
        .sheet(isPresented: $showingDirections) {
            DirectionsView(shop: shop)
        }
        .confirmationDialog("Call \(shop.name)", isPresented: $showingCallSheet) {
            Button("Call \(shop.phoneNumber)") {
                callShop()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shop.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("\(shop.rating, specifier: "%.1f") (\(shop.reviewCount) reviews)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(shop.isOpen ? "Open" : "Closed")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(shop.isOpen ? Color.green : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        Text("$$$$") // Placeholder price range
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(shop.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(String(format: "%.1f", shop.distanceFromUser)) miles away")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
    
    private var quickActionsSection: some View {
        HStack(spacing: 16) {
            ActionButton(
                icon: "location.fill",
                title: "Directions",
                action: { showingDirections = true }
            )
            
            ActionButton(
                icon: "phone.fill",
                title: "Call",
                action: { showingCallSheet = true }
            )
            
            ActionButton(
                icon: "square.and.arrow.up",
                title: "Share",
                action: shareShop
            )
        }
        .padding()
    }
    
    private var shopInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(shop.description)
                    .font(.body)
                    .padding(.horizontal)
                
                if !shop.amenities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(shop.amenities, id: \.self) { amenity in
                                Text(amenity.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hours")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 6) {
                // Placeholder for hours - need to implement proper hours structure
                ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { day in
                    HStack {
                        Text(day)
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)
                        
                        Text("8:00 AM - 6:00 PM")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Menu")
                .font(.headline)
                .padding(.horizontal)
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(menuCategories, id: \.self) { category in
                        CategoryFilterChip(
                            title: category,
                            isSelected: selectedMenuCategory == category
                        ) {
                            selectedMenuCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Menu Items
            LazyVStack(spacing: 0) {
                ForEach(filteredMenu) { item in
                    MenuItemRow(item: item) {
                        cartManager.addToCart(item, quantity: 1, customizations: [:], coffeeShopId: shop.id)
                    }
                    
                    if item.id != filteredMenu.last?.id {
                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
        }
    }
    
    private var cartOverlay: some View {
        NavigationLink(destination: CartView().environmentObject(cartManager)) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cartManager.cart.itemCount) items")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("View Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("$\(cartManager.cart.total, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.caption)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .padding()
        }
    }
    
    private func toggleFavorite() {
        // TODO: Implement favorite functionality
    }
    
    private func shareShop() {
        // TODO: Implement share functionality
    }
    
    private func callShop() {
        if let phoneNumber = shop.phoneNumber {
            if let url = URL(string: "tel://\(phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // Removed formatHours function as it's not needed with current implementation
}

// MARK: - Supporting Views

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .medium : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    let onAddToCart: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let calories = item.nutritionalInfo?.calories, calories > 0 {
                        Text("• \(calories) cal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onAddToCart) {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
        }
        .padding()
    }
}

struct DirectionsView: View {
    let shop: CoffeeShop
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Get Directions to")
                    .font(.headline)
                
                Text(shop.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(shop.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    DirectionButton(
                        title: "Open in Apple Maps",
                        icon: "location.fill",
                        action: { openInAppleMaps() }
                    )
                    
                    DirectionButton(
                        title: "Open in Google Maps",
                        icon: "globe",
                        action: { openInGoogleMaps() }
                    )
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func openInAppleMaps() {
        let coordinate = shop.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = shop.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func openInGoogleMaps() {
        let coordinate = shop.coordinate
        if let url = URL(string: "comgooglemaps://?daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback to web version
                if let webURL = URL(string: "https://maps.google.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)") {
                    UIApplication.shared.open(webURL)
                }
            }
        }
    }
}

struct DirectionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
    }
}

#Preview {
    let sampleShop = CoffeeShop(
        name: "Sample Coffee Shop",
        description: "A cozy coffee shop perfect for working and relaxing.",
        address: "123 Main St",
        latitude: 37.7749,
        longitude: -122.4194,
        phoneNumber: "(555) 123-4567",
        rating: 4.5,
        reviewCount: 120,
        hours: OpeningHours(
            monday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
            tuesday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
            wednesday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
            thursday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
            friday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
            saturday: DaySchedule(openHour: 8, openMinute: 0, closeHour: 20, closeMinute: 0),
            sunday: DaySchedule(openHour: 8, openMinute: 0, closeHour: 18, closeMinute: 0)
        ),
        amenities: [.wifi, .parking],
        menu: MenuItem.sampleMenuItems
    )
    CoffeeShopDetailView(shop: sampleShop)
}
