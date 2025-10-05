//
//  RootView.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var coffeeShopService: CoffeeShopService
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            // Start location services when app launches
            coffeeShopService.startLocationUpdates()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var orderManager = OrderManager()
    
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            NearbyView()
                .tabItem {
                    Label("Nearby", systemImage: "location")
                }
            
            CartView()
                .environmentObject(cartManager)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .badge(cartManager.cart.itemCount > 0 ? "\(cartManager.cart.itemCount)" : "")
            
            OrdersView()
                .environmentObject(orderManager)
                .tabItem {
                    Label("Orders", systemImage: "list.bullet.rectangle")
                }
            
            ProfileView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .accentColor(.brown)
    }
}

// Main Views
struct MapView: View {
    var body: some View {
        CoffeeMapView()
    }
}

struct NearbyView: View {
    var body: some View {
        NearbyShopsView()
    }
}

// Views are now implemented in their respective files:
// - CartView in Views/Cart/CartView.swift
// - OrdersView in Views/Orders/OrdersView.swift  
// - ProfileView in Views/Profile/ProfileView.swift

#Preview {
    RootView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CoffeeShopService())
        .environmentObject(CartManager())
        .environmentObject(OrderManager())
}