import SwiftUI

struct CoffeeShopsView: View {
    @StateObject private var viewModel = CoffeeShopsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List(viewModel.coffeeShops) { coffeeShop in
                        NavigationLink(destination: MenuView(coffeeShop: coffeeShop)) {
                            CoffeeShopRow(coffeeShop: coffeeShop)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Кофейни")
            .onAppear {
                viewModel.fetchCoffeeShops()
            }
        }
    }
}

struct CoffeeShopRow: View {
    let coffeeShop: CoffeeShop
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coffeeShop.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coffeeShop.name)
                    .font(.headline)
                
                Text(coffeeShop.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", coffeeShop.rating))
                    
                    Spacer()
                    
                    Text(coffeeShop.isOpen ? "Открыто" : "Закрыто")
                        .foregroundColor(coffeeShop.isOpen ? .green : .red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CoffeeShopsView()
} 