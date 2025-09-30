import Foundation
import Combine

class CoffeeShopsViewModel: ObservableObject {
    @Published var coffeeShops: [CoffeeShop] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCoffeeShops() {
        isLoading = true
        
        // Здесь будет реальный API-запрос
        // Пока используем моковые данные
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.coffeeShops = [
                CoffeeShop(
                    id: "1",
                    name: "Coffee House",
                    address: "ул. Пушкина, 10",
                    imageURL: "https://example.com/coffee1.jpg",
                    workingHours: "8:00 - 22:00",
                    rating: 4.5,
                    isOpen: true
                ),
                CoffeeShop(
                    id: "2",
                    name: "Coffee Time",
                    address: "ул. Лермонтова, 15",
                    imageURL: "https://example.com/coffee2.jpg",
                    workingHours: "9:00 - 23:00",
                    rating: 4.8,
                    isOpen: true
                )
            ]
            self.isLoading = false
        }
    }
} 