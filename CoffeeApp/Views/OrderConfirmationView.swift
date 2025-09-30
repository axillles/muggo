import SwiftUI

struct OrderConfirmationView: View {
    @ObservedObject var viewModel: MenuViewModel
    let coffeeShop: CoffeeShop
    let preparationTime: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isCreatingOrder = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Информация о заказе
                VStack(alignment: .leading, spacing: 12) {
                    Text("Подтверждение заказа")
                        .font(.title2)
                        .bold()
                    
                    Text("Кофейня: \(coffeeShop.name)")
                    Text("Адрес: \(coffeeShop.address)")
                    Text("Время приготовления: через \(preparationTime) минут")
                    
                    Divider()
                    
                    Text("Состав заказа:")
                        .font(.headline)
                    
                    ForEach(viewModel.cart) { item in
                        HStack {
                            Text("Товар \(item.menuItemId)") // Здесь нужно добавить название товара
                            Spacer()
                            Text("\(item.quantity) × \(Int(item.price)) ₽")
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Итого:")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(viewModel.totalPrice)) ₽")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Кнопка подтверждения
                Button(action: {
                    createOrder()
                }) {
                    if isCreatingOrder {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Подтвердить заказ")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .disabled(isCreatingOrder)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Подтверждение")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Заказ принят!"),
                    message: Text("Ваш заказ будет готов через \(preparationTime) минут."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func createOrder() {
        isCreatingOrder = true
        
        Task {
            do {
                _ = try await viewModel.createOrder(
                    coffeeShopId: coffeeShop.id,
                    preparationTime: preparationTime
                )
                
                await MainActor.run {
                    isCreatingOrder = false
                    showingSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isCreatingOrder = false
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    OrderConfirmationView(
        viewModel: MenuViewModel(),
        coffeeShop: CoffeeShop(
            id: "1",
            name: "Coffee House",
            address: "ул. Пушкина, 10",
            imageURL: "https://example.com/coffee1.jpg",
            workingHours: "8:00 - 22:00",
            rating: 4.5,
            isOpen: true
        ),
        preparationTime: 15
    )
} 