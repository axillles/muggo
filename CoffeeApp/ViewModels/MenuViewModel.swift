import Foundation
import Combine

class MenuViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var cart: [OrderItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchMenu(for coffeeShopId: String) {
        isLoading = true
        
        Task {
            do {
                let items = try await SupabaseService.shared.fetchMenuItems(for: coffeeShopId)
                await MainActor.run {
                    self.menuItems = items
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func addToCart(item: MenuItem) {
        if let index = cart.firstIndex(where: { $0.menuItemId == item.id }) {
            cart[index].quantity += 1
        } else {
            let orderItem = OrderItem(
                id: UUID().uuidString,
                menuItemId: item.id,
                quantity: 1,
                price: item.price
            )
            cart.append(orderItem)
        }
    }
    
    func removeFromCart(item: OrderItem) {
        if let index = cart.firstIndex(where: { $0.id == item.id }) {
            cart.remove(at: index)
        }
    }
    
    func createOrder(coffeeShopId: String, preparationTime: Int) async throws -> Order {
        let order = Order(
            id: UUID().uuidString,
            coffeeShopId: coffeeShopId,
            items: cart,
            totalPrice: totalPrice,
            preparationTime: preparationTime,
            orderDate: Date(),
            status: .pending
        )
        
        return try await SupabaseService.shared.createOrder(order)
    }
    
    var totalPrice: Double {
        cart.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
} 