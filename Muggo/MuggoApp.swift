//
//  MuggoApp.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import SwiftUI

@main
struct MuggoApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var coffeeShopService = CoffeeShopService()
    @StateObject private var cartManager = CartManager()
    @StateObject private var orderManager = OrderManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(authManager)
                .environmentObject(coffeeShopService)
                .environmentObject(cartManager)
                .environmentObject(orderManager)
        }
    }
}
