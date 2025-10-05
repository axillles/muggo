//
//  Order.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import SwiftUI

struct Order: Codable, Identifiable {
    let id: UUID
    var orderNumber: String
    var userId: UUID
    var coffeeShopId: UUID
    var items: [OrderItem]
    var subtotal: Double
    var tax: Double
    var tip: Double
    var total: Double
    var status: OrderStatus
    var paymentMethod: PaymentMethod
    var transactionId: String?
    var estimatedPickupTime: Date
    var actualPickupTime: Date?
    var specialInstructions: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), orderNumber: String = "", userId: UUID, coffeeShopId: UUID, items: [OrderItem], subtotal: Double, tax: Double, tip: Double, total: Double, status: OrderStatus = .placed, paymentMethod: PaymentMethod, transactionId: String? = nil, estimatedPickupTime: Date, actualPickupTime: Date? = nil, specialInstructions: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.orderNumber = orderNumber.isEmpty ? Order.generateOrderNumber() : orderNumber
        self.userId = userId
        self.coffeeShopId = coffeeShopId
        self.items = items
        self.subtotal = subtotal
        self.tax = tax
        self.tip = tip
        self.total = total
        self.status = status
        self.paymentMethod = paymentMethod
        self.transactionId = transactionId
        self.estimatedPickupTime = estimatedPickupTime
        self.actualPickupTime = actualPickupTime
        self.specialInstructions = specialInstructions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var formattedTotal: String {
        String(format: "$%.2f", total)
    }
    
    var formattedSubtotal: String {
        String(format: "$%.2f", subtotal)
    }
    
    var formattedTax: String {
        String(format: "$%.2f", tax)
    }
    
    var formattedTip: String {
        String(format: "$%.2f", tip)
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var estimatedPrepTime: Int {
        items.reduce(0) { max($0, $1.menuItem.estimatedPrepTime) }
    }
    
    var isActive: Bool {
        status == .placed || status == .confirmed || status == .preparing
    }
    
    var canCancel: Bool {
        status == .placed || status == .confirmed
    }
    
    static func generateOrderNumber() -> String {
        let timestamp = Date().timeIntervalSince1970
        let random = Int.random(in: 100...999)
        return String(format: "%03d", random)
    }
    
    static func createFromCart(_ cart: Cart, userId: UUID, paymentMethod: PaymentMethod, tip: Double = 0, specialInstructions: String? = nil) -> Order? {
        guard !cart.isEmpty, let coffeeShopId = cart.coffeeShopId else { return nil }
        
        let orderItems = cart.items.map { cartItem in
            OrderItem(
                id: cartItem.id,
                menuItem: cartItem.menuItem,
                quantity: cartItem.quantity,
                selectedCustomizations: cartItem.selectedCustomizations,
                unitPrice: cartItem.menuItem.price,
                totalPrice: cartItem.totalPrice
            )
        }
        
        let subtotal = cart.subtotal
        let tax = cart.tax
        let total = subtotal + tax + tip
        
        let estimatedPickupTime = Calendar.current.date(
            byAdding: .minute,
            value: cart.estimatedPrepTime,
            to: Date()
        ) ?? Date()
        
        return Order(
            userId: userId,
            coffeeShopId: coffeeShopId,
            items: orderItems,
            subtotal: subtotal,
            tax: tax,
            tip: tip,
            total: total,
            paymentMethod: paymentMethod,
            estimatedPickupTime: estimatedPickupTime,
            specialInstructions: specialInstructions
        )
    }
}

struct OrderItem: Codable, Identifiable {
    let id: UUID
    var menuItem: MenuItem
    var quantity: Int
    var selectedCustomizations: [UUID: [UUID]]
    var unitPrice: Double
    var totalPrice: Double
    
    init(id: UUID = UUID(), menuItem: MenuItem, quantity: Int, selectedCustomizations: [UUID: [UUID]] = [:], unitPrice: Double, totalPrice: Double) {
        self.id = id
        self.menuItem = menuItem
        self.quantity = quantity
        self.selectedCustomizations = selectedCustomizations
        self.unitPrice = unitPrice
        self.totalPrice = totalPrice
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

enum OrderStatus: String, CaseIterable, Codable {
    case placed = "Placed"
    case confirmed = "Confirmed"
    case preparing = "Preparing"
    case ready = "Ready for Pickup"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .placed: return .orange
        case .confirmed: return .blue
        case .preparing: return .purple
        case .ready: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .placed: return "clock"
        case .confirmed: return "checkmark.circle"
        case .preparing: return "flame"
        case .ready: return "bell"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        }
    }
    
    var description: String {
        switch self {
        case .placed: return "Order has been placed and is waiting for confirmation"
        case .confirmed: return "Order confirmed by the coffee shop"
        case .preparing: return "Your order is being prepared"
        case .ready: return "Your order is ready for pickup!"
        case .completed: return "Order has been completed"
        case .cancelled: return "Order was cancelled"
        }
    }
}

enum PaymentMethod: String, CaseIterable, Codable {
    case applePay = "Apple Pay"
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case cash = "Cash"
    case giftCard = "Gift Card"
    
    var icon: String {
        switch self {
        case .applePay: return "apple.logo"
        case .creditCard: return "creditcard"
        case .debitCard: return "creditcard.fill"
        case .cash: return "banknote"
        case .giftCard: return "gift"
        }
    }
}

// MARK: - Order Manager
class OrderManager: ObservableObject {
    @Published var orders: [Order] = []
    @Published var activeOrders: [Order] = []
    
    private let userDefaults = UserDefaults.standard
    private let ordersKey = "SavedOrders"
    
    init() {
        loadOrders()
        updateActiveOrders()
    }
    
    func placeOrder(_ order: Order) {
        orders.append(order)
        saveOrders()
        updateActiveOrders()
    }
    
    func updateOrderStatus(_ orderId: UUID, status: OrderStatus) {
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else { return }
        orders[index].status = status
        orders[index].updatedAt = Date()
        
        if status == .completed {
            orders[index].actualPickupTime = Date()
        }
        
        saveOrders()
        updateActiveOrders()
    }
    
    func cancelOrder(_ orderId: UUID) {
        updateOrderStatus(orderId, status: .cancelled)
    }
    
    private func updateActiveOrders() {
        activeOrders = orders.filter { $0.isActive }
    }
    
    private func saveOrders() {
        if let encoded = try? JSONEncoder().encode(orders) {
            userDefaults.set(encoded, forKey: ordersKey)
        }
    }
    
    private func loadOrders() {
        if let data = userDefaults.data(forKey: ordersKey),
           let savedOrders = try? JSONDecoder().decode([Order].self, from: data) {
            orders = savedOrders
        }
    }
    
    func getOrderHistory(for userId: UUID) -> [Order] {
        return orders.filter { $0.userId == userId }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getActiveOrders(for userId: UUID) -> [Order] {
        return activeOrders.filter { $0.userId == userId }.sorted { $0.createdAt > $1.createdAt }
    }
}

// MARK: - Sample Data
extension Order {
    static let sampleOrders = [
        Order(
            orderNumber: "157",
            userId: UUID(),
            coffeeShopId: UUID(),
            items: [
                OrderItem(
                    menuItem: MenuItem.sampleMenuItems[0],
                    quantity: 2,
                    selectedCustomizations: [:],
                    unitPrice: 3.25,
                    totalPrice: 6.50
                ),
                OrderItem(
                    menuItem: MenuItem.sampleMenuItems[3], // Croissant
                    quantity: 1,
                    selectedCustomizations: [:],
                    unitPrice: 2.95,
                    totalPrice: 2.95
                )
            ],
            subtotal: 9.45,
            tax: 0.84,
            tip: 1.70,
            total: 11.99,
            status: .preparing,
            paymentMethod: .applePay,
            estimatedPickupTime: Calendar.current.date(byAdding: .minute, value: 8, to: Date()) ?? Date(),
            createdAt: Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date()
        ),
        Order(
            orderNumber: "142",
            userId: UUID(),
            coffeeShopId: UUID(),
            items: [
                OrderItem(
                    menuItem: MenuItem.sampleMenuItems[1],
                    quantity: 1,
                    selectedCustomizations: [:],
                    unitPrice: 4.25,
                    totalPrice: 4.25
                )
            ],
            subtotal: 4.25,
            tax: 0.38,
            tip: 0.77,
            total: 5.40,
            status: .completed,
            paymentMethod: .creditCard,
            estimatedPickupTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            actualPickupTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            createdAt: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
        )
    ]
}