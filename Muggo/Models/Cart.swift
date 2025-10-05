//
//  Cart.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import SwiftUI

struct Cart: Codable {
    var items: [CartItem]
    var coffeeShopId: UUID?
    var lastUpdated: Date
    
    init(items: [CartItem] = [], coffeeShopId: UUID? = nil, lastUpdated: Date = Date()) {
        self.items = items
        self.coffeeShopId = coffeeShopId
        self.lastUpdated = lastUpdated
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var tax: Double {
        subtotal * 0.08875 // Example tax rate
    }
    
    var tip: Double {
        subtotal * 0.18 // Default 18% tip
    }
    
    var total: Double {
        subtotal + tax + tip
    }
    
    var estimatedPrepTime: Int {
        items.reduce(0) { max($0, $1.menuItem.estimatedPrepTime) }
    }
    
    mutating func addItem(_ menuItem: MenuItem, quantity: Int = 1, selectedCustomizations: [UUID: [UUID]] = [:]) {
        // Check if the same item with same customizations exists
        if let existingIndex = items.firstIndex(where: { 
            $0.menuItem.id == menuItem.id && 
            $0.selectedCustomizations == selectedCustomizations 
        }) {
            items[existingIndex].quantity += quantity
        } else {
            let cartItem = CartItem(
                menuItem: menuItem,
                quantity: quantity,
                selectedCustomizations: selectedCustomizations
            )
            items.append(cartItem)
        }
        lastUpdated = Date()
    }
    
    mutating func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        lastUpdated = Date()
    }
    
    mutating func updateQuantity(for itemId: UUID, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
        lastUpdated = Date()
    }
    
    mutating func clear() {
        items.removeAll()
        coffeeShopId = nil
        lastUpdated = Date()
    }
}

struct CartItem: Codable, Identifiable {
    let id: UUID
    var menuItem: MenuItem
    var quantity: Int
    var selectedCustomizations: [UUID: [UUID]] // CustomizationID: [SelectedOptionIDs]
    let addedAt: Date
    
    init(id: UUID = UUID(), menuItem: MenuItem, quantity: Int = 1, selectedCustomizations: [UUID: [UUID]] = [:], addedAt: Date = Date()) {
        self.id = id
        self.menuItem = menuItem
        self.quantity = quantity
        self.selectedCustomizations = selectedCustomizations
        self.addedAt = addedAt
    }
    
    var basePrice: Double {
        menuItem.price * Double(quantity)
    }
    
    var customizationPrice: Double {
        var total: Double = 0
        
        for (customizationId, selectedOptionIds) in selectedCustomizations {
            guard let customization = menuItem.customizations.first(where: { $0.id == customizationId }) else { continue }
            
            for optionId in selectedOptionIds {
                if let option = customization.options.first(where: { $0.id == optionId }) {
                    total += option.priceModifier * Double(quantity)
                }
            }
        }
        
        return total
    }
    
    var totalPrice: Double {
        basePrice + customizationPrice
    }
    
    var formattedTotalPrice: String {
        String(format: "$%.2f", totalPrice)
    }
    
    func getSelectedOptionsText() -> String {
        var optionsText: [String] = []
        
        for (customizationId, selectedOptionIds) in selectedCustomizations {
            guard let customization = menuItem.customizations.first(where: { $0.id == customizationId }) else { continue }
            
            let selectedOptions = selectedOptionIds.compactMap { optionId in
                customization.options.first(where: { $0.id == optionId })?.name
            }
            
            if !selectedOptions.isEmpty {
                optionsText.append("\(customization.name): \(selectedOptions.joined(separator: ", "))")
            }
        }
        
        return optionsText.joined(separator: " • ")
    }
}

// MARK: - Cart Manager
class CartManager: ObservableObject {
    @Published var cart = Cart()
    
    private let userDefaults = UserDefaults.standard
    private let cartKey = "SavedCart"
    
    init() {
        loadCart()
    }
    
    func addToCart(_ menuItem: MenuItem, quantity: Int = 1, customizations: [UUID: [UUID]] = [:], coffeeShopId: UUID) {
        // If adding from different coffee shop, clear cart first
        if let currentShopId = cart.coffeeShopId, currentShopId != coffeeShopId {
            cart.clear()
        }
        
        cart.coffeeShopId = coffeeShopId
        cart.addItem(menuItem, quantity: quantity, selectedCustomizations: customizations)
        saveCart()
    }
    
    func removeFromCart(at index: Int) {
        cart.removeItem(at: index)
        saveCart()
    }
    
    func updateQuantity(for itemId: UUID, quantity: Int) {
        cart.updateQuantity(for: itemId, quantity: quantity)
        saveCart()
    }
    
    func clearCart() {
        cart.clear()
        saveCart()
    }
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(cart) {
            userDefaults.set(encoded, forKey: cartKey)
        }
    }
    
    private func loadCart() {
        if let data = userDefaults.data(forKey: cartKey),
           let savedCart = try? JSONDecoder().decode(Cart.self, from: data) {
            cart = savedCart
        }
    }
}

// MARK: - Sample Data
extension Cart {
    static let sampleCart = Cart(
        items: [
            CartItem(
                menuItem: MenuItem.sampleMenuItems[0], // Americano
                quantity: 2,
                selectedCustomizations: [
                    MenuItem.sampleMenuItems[0].customizations[0].id: [MenuItem.sampleMenuItems[0].customizations[0].options[2].id] // Large
                ]
            ),
            CartItem(
                menuItem: MenuItem.sampleMenuItems[1], // Cappuccino
                quantity: 1,
                selectedCustomizations: [
                    MenuItem.sampleMenuItems[1].customizations[0].id: [MenuItem.sampleMenuItems[1].customizations[0].options[1].id], // Medium
                    MenuItem.sampleMenuItems[1].customizations[1].id: [MenuItem.sampleMenuItems[1].customizations[1].options[2].id] // Oat Milk
                ]
            )
        ],
        coffeeShopId: UUID()
    )
}