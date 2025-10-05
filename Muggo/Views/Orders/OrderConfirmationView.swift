//
//  OrderConfirmationView.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import SwiftUI

struct OrderConfirmationView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coffeeShopService: CoffeeShopService
    
    private var coffeeShop: CoffeeShop? {
        coffeeShopService.coffeeShops.first { $0.id == order.coffeeShopId }
    }
    
    private var estimatedWaitTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: order.estimatedPickupTime)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Success Animation
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Order Confirmed!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Thank you for your order")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Order Details
                    OrderDetailsSection()
                    
                    // Pickup Information
                    PickupInfoSection()
                    
                    // Order Items
                    OrderItemsSection()
                    
                    // Action Buttons
                    ActionButtonsSection()
                }
                .padding()
            }
            .navigationTitle("Order #\(order.orderNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func OrderDetailsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order Number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("#\(order.orderNumber)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", order.total))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payment Method")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: order.paymentMethod.icon)
                        Text(order.paymentMethod.rawValue)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Circle()
                            .fill(order.status.color)
                            .frame(width: 8, height: 8)
                        Text(order.status.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func PickupInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pickup Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let shop = coffeeShop {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.brown)
                        Text(shop.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(shop.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ready by \(estimatedWaitTime)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("We'll notify you when it's ready")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let phoneNumber = shop.phoneNumber {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                            Text(phoneNumber)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func OrderItemsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Items")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(order.items, id: \.id) { item in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.menuItem.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if !item.getSelectedOptionsText().isEmpty {
                            Text(item.getSelectedOptionsText())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("×\(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(item.formattedTotalPrice)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .padding(.vertical, 4)
                
                if item.id != order.items.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func ActionButtonsSection() -> some View {
        VStack(spacing: 12) {
            // Track Order Button
            Button(action: {
                // TODO: Navigate to order tracking
            }) {
                HStack {
                    Image(systemName: "location.magnifyingglass")
                    Text("Track Order")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown)
                .cornerRadius(12)
            }
            
            // Contact Shop Button
            if let shop = coffeeShop, shop.phoneNumber != nil {
                Button(action: {
                    if let phoneNumber = shop.phoneNumber,
                       let url = URL(string: "tel:\(phoneNumber)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Contact \(shop.name)")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
}

#Preview {
    OrderConfirmationView(order: Order.sampleOrders[0])
        .environmentObject(CoffeeShopService())
}