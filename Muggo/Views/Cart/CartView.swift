import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartManager
    @State private var showingCheckout = false
    @State private var specialInstructions = ""
    @State private var selectedPickupTime = Date()
    @Environment(\.dismiss) private var dismiss
    
    private var pickupTimeOptions: [Date] {
        let now = Date()
        let calendar = Calendar.current
        var times: [Date] = []
        
        // Generate pickup times for the next 4 hours in 15-minute intervals
        for i in 1...16 {
            if let time = calendar.date(byAdding: .minute, value: i * 15, to: now) {
                times.append(time)
            }
        }
        return times
    }
    
    var body: some View {
        NavigationView {
            Group {
            if cartManager.cart.items.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView()
        }
        .onAppear {
            if let firstTime = pickupTimeOptions.first {
                selectedPickupTime = firstTime
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("Your cart is empty")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Add items from coffee shops to start your order")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Find Coffee Shops") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Shop header
                    // TODO: Add shop name lookup
                    let shopName = "Coffee Shop"
                    shopHeaderView(shopName: shopName)
                    
                    // Cart items
                    VStack(spacing: 0) {
                        ForEach(cartManager.cart.items) { cartItem in
                            CartItemRow(
                                cartItem: cartItem,
                                onQuantityChange: { newQuantity in
                                    cartManager.updateQuantity(for: cartItem.id, quantity: newQuantity)
                                },
                                onRemove: {
                                    if let index = cartManager.cart.items.firstIndex(where: { $0.id == cartItem.id }) {
                                        cartManager.removeFromCart(at: index)
                                    }
                                }
                            )
                            
                            if cartItem.id != cartManager.cart.items.last?.id {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Pickup time selection
                    pickupTimeSection
                    
                    // Special instructions
                    specialInstructionsSection
                    
                    // Order summary
                    orderSummarySection
                    
                    Spacer(minLength: 100) // Space for checkout button
                }
                .padding()
            }
            
            // Checkout button
            checkoutButton
        }
    }
    
    private func shopHeaderView(shopName: String) -> some View {
        HStack {
            Image(systemName: "storefront")
                .font(.title3)
                .foregroundColor(.blue)
            
            Text("Order from \(shopName)")
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var pickupTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pickup Time")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(pickupTimeOptions, id: \.self) { time in
                        PickupTimeChip(
                            time: time,
                            isSelected: time == selectedPickupTime
                        ) {
                            selectedPickupTime = time
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var specialInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special Instructions")
                .font(.headline)
            
            TextField("Any special requests or dietary restrictions?", text: $specialInstructions, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
        .padding(.vertical)
    }
    
    private var orderSummarySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Order Summary")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal")
                        .font(.body)
                    Spacer()
                    Text("$\(cartManager.cart.subtotal, specifier: "%.2f")")
                        .font(.body)
                }
                
                HStack {
                    Text("Tax")
                        .font(.body)
                    Spacer()
                    Text("$\(cartManager.cart.tax, specifier: "%.2f")")
                        .font(.body)
                }
                
                // Service fee (placeholder)
                let serviceFee = 1.99
                if serviceFee > 0 {
                    HStack {
                        Text("Service Fee")
                            .font(.body)
                        Spacer()
                        Text("$\(serviceFee, specifier: "%.2f")")
                            .font(.body)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(cartManager.cart.total, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.vertical)
    }
    
    private var checkoutButton: some View {
        VStack(spacing: 12) {
            Divider()
            
            Button(action: {
                showingCheckout = true
            }) {
                HStack {
                    Text("Continue to Checkout")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("$\(cartManager.cart.total, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
    }
}

struct CartItemRow: View {
    let cartItem: CartItem
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void
    @State private var showingRemoveAlert = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(cartItem.menuItem.name)
                    .font(.headline)
                
                let selectedOptionsText = cartItem.getSelectedOptionsText()
                if !selectedOptionsText.isEmpty {
                    Text(selectedOptionsText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("$\(cartItem.menuItem.price, specifier: "%.2f") each")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                Text("$\(cartItem.totalPrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack(spacing: 0) {
                    Button(action: {
                        if cartItem.quantity > 1 {
                            onQuantityChange(cartItem.quantity - 1)
                        } else {
                            showingRemoveAlert = true
                        }
                    }) {
                        Image(systemName: cartItem.quantity > 1 ? "minus" : "trash")
                            .font(.caption)
                            .foregroundColor(cartItem.quantity > 1 ? .blue : .red)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    
                    Text("\(cartItem.quantity)")
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(width: 40)
                    
                    Button(action: {
                        onQuantityChange(cartItem.quantity + 1)
                    }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .alert("Remove Item", isPresented: $showingRemoveAlert) {
            Button("Remove", role: .destructive) {
                onRemove()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove \(cartItem.menuItem.name) from your cart?")
        }
    }
}

struct PickupTimeChip: View {
    let time: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    var body: some View {
        Button(action: action) {
            Text(timeString)
                .font(.subheadline)
                .fontWeight(isSelected ? .medium : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager())
}
