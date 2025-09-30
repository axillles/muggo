import Foundation

final class OrderConfirmationViewModel: ObservableObject {
    @Published var orderNumber: String = ""
    @Published var etaMinutes: Int = 10
    
    func generate(order: Order) {
        orderNumber = String(order.id.suffix(6)).uppercased()
        etaMinutes = order.preparationTime
    }
}


