import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String?
    let displayName: String?
}

struct CoffeeShop: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let imageURL: String
    let workingHours: String
    let rating: Double
    var isOpen: Bool
}

struct MenuItem: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String
    let category: MenuCategory
    let preparationTime: Int // время приготовления в минутах
}

enum MenuCategory: String, Codable, CaseIterable {
    case coffee
    case tea
    case desserts
    case sandwiches
}

struct Order: Identifiable, Codable {
    let id: String
    let coffeeShopId: String
    let items: [OrderItem]
    let totalPrice: Double
    let preparationTime: Int // через сколько приготовить
    let orderDate: Date
    let status: OrderStatus
}

struct OrderItem: Identifiable, Codable {
    let id: String
    let menuItemId: String
    var quantity: Int
    let price: Double
}

enum OrderStatus: String, Codable {
    case pending
    case preparing
    case ready
    case completed
    case cancelled
} 