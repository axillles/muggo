//
//  CoffeeMapView.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import SwiftUI
import MapKit
import CoreLocation

struct CoffeeMapView: View {
    @EnvironmentObject var coffeeShopService: CoffeeShopService
    @EnvironmentObject var cartManager: CartManager
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedShop: CoffeeShop?
    @State private var showingShopDetail = false
    @State private var showingLocationPermission = false
    @State private var searchText = ""
    @State private var showingSearch = false
    
    var filteredShops: [CoffeeShop] {
        if searchText.isEmpty {
            return coffeeShopService.coffeeShops
        } else {
            return coffeeShopService.searchCoffeeShops(query: searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map View
                Map(coordinateRegion: $region, 
                    interactionModes: [.all],
                    showsUserLocation: true,
                    annotationItems: filteredShops) { shop in
                    MapAnnotation(coordinate: shop.coordinate) {
                        CoffeeShopMapPin(shop: shop) {
                            selectedShop = shop
                            showingShopDetail = true
                        }
                    }
                }
                .ignoresSafeArea(edges: .horizontal)
                .onAppear {
                    coffeeShopService.startLocationUpdates()
                    setupInitialRegion()
                }
                
                // Search Bar
                if showingSearch {
                    SearchBarView(searchText: $searchText, isShowing: $showingSearch)
                        .padding()
                        .background(Color.black.opacity(0.1))
                }
                
                // Floating Action Buttons
                VStack {
                    Spacer()
                    HStack {
                        // Search Button
                        FloatingActionButton(
                            icon: "magnifyingglass",
                            color: .white,
                            backgroundColor: .brown
                        ) {
                            withAnimation {
                                showingSearch.toggle()
                                if !showingSearch {
                                    searchText = ""
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Current Location Button
                        FloatingActionButton(
                            icon: "location.fill",
                            color: .white,
                            backgroundColor: .blue
                        ) {
                            centerOnUserLocation()
                        }
                        
                        // Refresh Button
                        FloatingActionButton(
                            icon: "arrow.clockwise",
                            color: .white,
                            backgroundColor: .green
                        ) {
                            Task {
                                await coffeeShopService.refreshCoffeeShops()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Account for tab bar
                }
            }
            .navigationTitle("Coffee Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Show filter options
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $showingShopDetail) {
                if let shop = selectedShop {
                    CoffeeShopDetailView(shop: shop)
                }
            }
            .alert("Location Permission Required", isPresented: $showingLocationPermission) {
                Button("Settings") {
                    openAppSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable location access to find nearby coffee shops.")
            }
        }
    }
    
    private func setupInitialRegion() {
        // If we have user location, center on that
        if let userLocation = coffeeShopService.userLocation {
            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        } else {
            // Otherwise, center on the first coffee shop or use default
            if let firstShop = coffeeShopService.coffeeShops.first {
                region = MKCoordinateRegion(
                    center: firstShop.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    private func centerOnUserLocation() {
        guard let userLocation = coffeeShopService.userLocation else {
            showingLocationPermission = true
            return
        }
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct CoffeeShopMapPin: View {
    let shop: CoffeeShop
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Pin icon
            ZStack {
                Circle()
                    .fill(shop.isOpen ? Color.green : Color.red)
                    .frame(width: 32, height: 32)
                    .shadow(radius: 3)
                
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
            
            // Pin tail
            Triangle()
                .fill(shop.isOpen ? Color.green : Color.red)
                .frame(width: 12, height: 8)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .scaleEffect(1.0)
        .onTapGesture {
            onTap()
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack {
            TextField("Search coffee shops...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button("Cancel") {
                searchText = ""
                isShowing = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .foregroundColor(.brown)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
}


#Preview {
    CoffeeMapView()
        .environmentObject(CoffeeShopService())
        .environmentObject(CartManager())
}