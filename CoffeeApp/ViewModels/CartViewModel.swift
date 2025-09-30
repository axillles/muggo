import Foundation

final class CartViewModel: ObservableObject {
    @Published var items: [OrderItem] = []
    
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    func add(_ item: OrderItem) {
        if let index = items.firstIndex(where: { $0.menuItemId == item.menuItemId }) {
            items[index].quantity += item.quantity
        } else {
            items.append(item)
        }
    }
    
    func remove(_ item: OrderItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
    }
    
    func clear() {
        items.removeAll()
    }
}


