//
//  CoffeeAppApp.swift
//  CoffeeApp
//
//  Created by Артем Гаврилов on 21.04.25.
//

import SwiftUI

@main
struct CoffeeAppApp: App {
    init() {
        FirebaseManager.configureIfNeeded()
    }
    var body: some Scene {
        WindowGroup {
            CoffeeShopsView()
        }
    }
}
