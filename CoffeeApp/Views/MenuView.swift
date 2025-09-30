import SwiftUI

struct MenuView: View {
    let coffeeShop: CoffeeShop
    @StateObject private var viewModel = MenuViewModel()
    @State private var selectedCategory: MenuCategory?
    @State private var showingCart = false
    
    var filteredItems: [MenuItem] {
        if let category = selectedCategory {
            return viewModel.menuItems.filter { $0.category == category }
        }
        return viewModel.menuItems
    }
    
    var body: some View {
        VStack {
            // Категории
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Кнопка "Все"
                    CategoryButton(
                        title: "Все",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    // Кнопки категорий
                    ForEach(MenuCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue.capitalized,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding()
            }
            
            // Список товаров
            List(filteredItems) { item in
                MenuItemRow(item: item) {
                    viewModel.addToCart(item: item)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(coffeeShop.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingCart = true
                }) {
                    Image(systemName: "cart")
                        .overlay(
                            Text("\(viewModel.cart.count)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        )
                }
            }
        }
        .sheet(isPresented: $showingCart) {
            CartView(viewModel: viewModel, coffeeShop: coffeeShop)
        }
        .onAppear {
            viewModel.fetchMenu(for: coffeeShop.id)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.blue : Color.gray.opacity(0.2)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    let onAddToCart: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("\(Int(item.price)) ₽")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: onAddToCart) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        MenuView(coffeeShop: CoffeeShop(
            id: "1",
            name: "Coffee House",
            address: "ул. Пушкина, 10",
            imageURL: "https://example.com/coffee1.jpg",
            workingHours: "8:00 - 22:00",
            rating: 4.5,
            isOpen: true
        ))
    }
} 