import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: MenuViewModel
    let coffeeShop: CoffeeShop
    @State private var preparationTime = 15
    @State private var showingOrderConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.cart.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Корзина пуста")
                            .font(.title2)
                        Text("Добавьте товары из меню")
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.cart) { item in
                            CartItemRow(item: item) {
                                viewModel.removeFromCart(item: item)
                            }
                        }
                        
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Время приготовления")
                                    .font(.headline)
                                
                                Stepper(
                                    "Через \(preparationTime) минут",
                                    value: $preparationTime,
                                    in: 5...60,
                                    step: 5
                                )
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Section {
                            HStack {
                                Text("Итого")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(viewModel.totalPrice)) ₽")
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Корзина")
            .navigationBarItems(trailing: Button(action: {
                showingOrderConfirmation = true
            }) {
                Text("Оформить заказ")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(viewModel.cart.isEmpty))
            .sheet(isPresented: $showingOrderConfirmation) {
                OrderConfirmationView(
                    viewModel: viewModel,
                    coffeeShop: coffeeShop,
                    preparationTime: preparationTime
                )
            }
        }
    }
}

struct CartItemRow: View {
    let item: OrderItem
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Товар \(item.menuItemId)") // Здесь нужно добавить название товара
                    .font(.headline)
                Text("\(Int(item.price)) ₽ × \(item.quantity)")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    CartView(
        viewModel: MenuViewModel(),
        coffeeShop: CoffeeShop(
            id: "1",
            name: "Coffee House",
            address: "ул. Пушкина, 10",
            imageURL: "https://example.com/coffee1.jpg",
            workingHours: "8:00 - 22:00",
            rating: 4.5,
            isOpen: true
        )
    )
} 