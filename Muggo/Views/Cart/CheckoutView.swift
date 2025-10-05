//
//  CheckoutView.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import SwiftUI
import PassKit

struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var orderManager: OrderManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var coffeeShopService: CoffeeShopService
    
    @StateObject private var paymentService = PaymentService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPaymentMethod: PaymentMethod = .applePay
    @State private var tipPercentage: Double = 0.15
    @State private var showingApplePay = false
    @State private var showingPaymentError = false
    @State private var paymentErrorMessage = ""
    @State private var showingOrderConfirmation = false
    @State private var confirmedOrder: Order?
    
    private var coffeeShop: CoffeeShop? {
        guard let shopId = cartManager.cart.coffeeShopId else { return nil }
        return coffeeShopService.coffeeShops.first { $0.id == shopId }
    }
    
    private var subtotal: Double {
        cartManager.cart.subtotal
    }
    
    private var tax: Double {
        subtotal * 0.0875 // 8.75% tax
    }
    
    private var tipAmount: Double {
        subtotal * tipPercentage
    }
    
    private var total: Double {
        subtotal + tax + tipAmount
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Coffee Shop Info
                    if let shop = coffeeShop {
                        CoffeeShopHeaderView(shop: shop)
                    }
                    
                    // Order Summary
                    OrderSummarySection()
                    
                    // Tip Selection
                    TipSelectionSection()
                    
                    // Payment Method Selection
                    PaymentMethodSection()
                    
                    // Order Total
                    OrderTotalSection()
                    
                    // Place Order Button
                    PlaceOrderButton()
                }
                .padding()
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Payment Error", isPresented: $showingPaymentError) {
                Button("OK") {}
            } message: {
                Text(paymentErrorMessage)
            }
            .sheet(isPresented: $showingOrderConfirmation) {
                if let order = confirmedOrder {
                    OrderConfirmationView(order: order)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func CoffeeShopHeaderView(shop: CoffeeShop) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.brown)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(shop.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(shop.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func OrderSummarySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(cartManager.cart.items, id: \.id) { item in
                HStack {
                    VStack(alignment: .leading) {
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
                    
                    Text("×\(item.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(item.formattedTotalPrice)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func TipSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tip")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach([0.15, 0.18, 0.20, 0.25], id: \.self) { percentage in
                    Button(action: {
                        tipPercentage = percentage
                    }) {
                        Text("\(Int(percentage * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(tipPercentage == percentage ? .white : .brown)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(tipPercentage == percentage ? Color.brown : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.brown, lineWidth: 1)
                            )
                            .cornerRadius(8)
                    }
                }
                
                Button(action: {
                    tipPercentage = 0
                }) {
                    Text("No Tip")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(tipPercentage == 0 ? .white : .brown)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(tipPercentage == 0 ? Color.brown : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brown, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func PaymentMethodSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                if paymentService.canMakePaymentsUsingNetworks() {
                    PaymentMethodRow(
                        paymentMethod: .applePay,
                        isSelected: selectedPaymentMethod == .applePay
                    ) {
                        selectedPaymentMethod = .applePay
                    }
                }
                
                PaymentMethodRow(
                    paymentMethod: .creditCard,
                    isSelected: selectedPaymentMethod == .creditCard
                ) {
                    selectedPaymentMethod = .creditCard
                }
                
                PaymentMethodRow(
                    paymentMethod: .cash,
                    isSelected: selectedPaymentMethod == .cash
                ) {
                    selectedPaymentMethod = .cash
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func OrderTotalSection() -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Subtotal")
                Spacer()
                Text(String(format: "$%.2f", subtotal))
            }
            
            HStack {
                Text("Tax")
                Spacer()
                Text(String(format: "$%.2f", tax))
            }
            
            HStack {
                Text("Tip")
                Spacer()
                Text(String(format: "$%.2f", tipAmount))
            }
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "$%.2f", total))
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func PlaceOrderButton() -> some View {
        Button(action: placeOrder) {
            HStack {
                if paymentService.isProcessingPayment {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: selectedPaymentMethod == .applePay ? "apple.logo" : "creditcard")
                    Text(selectedPaymentMethod == .applePay ? "Pay with Apple Pay" : "Place Order")
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(paymentService.isProcessingPayment ? Color.gray : Color.brown)
            .cornerRadius(12)
        }
        .disabled(paymentService.isProcessingPayment)
    }
    
    // MARK: - Actions
    
    private func placeOrder() {
        guard let user = authManager.currentUser,
              let coffeeShop = coffeeShop else { return }
        
        let order = Order(
            orderNumber: String(format: "%03d", Int.random(in: 100...999)),
            userId: user.id,
            coffeeShopId: coffeeShop.id,
            items: cartManager.cart.items.map { cartItem in
                OrderItem(
                    menuItem: cartItem.menuItem,
                    quantity: cartItem.quantity,
                    selectedCustomizations: cartItem.selectedCustomizations,
                    unitPrice: cartItem.menuItem.price,
                    totalPrice: cartItem.totalPrice
                )
            },
            subtotal: subtotal,
            tax: tax,
            tip: tipAmount,
            total: total,
            status: .placed,
            paymentMethod: selectedPaymentMethod,
            estimatedPickupTime: Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        )
        
        if selectedPaymentMethod == .applePay && paymentService.canMakePaymentsUsingNetworks() {
            // Process Apple Pay
            let request = paymentService.createApplePayRequest(for: order)
            let controller = PKPaymentAuthorizationController(paymentRequest: request)
            controller.delegate = ApplePayDelegate(
                paymentService: paymentService,
                order: order
            ) { result in
                handlePaymentResult(result, order: order)
            }
            controller.present()
        } else {
            // Process other payment methods
            paymentService.processPayment(for: order, paymentMethod: selectedPaymentMethod) { result in
                handlePaymentResult(result, order: order)
            }
        }
    }
    
    private func handlePaymentResult(_ result: Result<String, PaymentError>, order: Order) {
        switch result {
        case .success(let transactionId):
            var confirmedOrder = order
            confirmedOrder.transactionId = transactionId
            confirmedOrder.status = .confirmed
            
            orderManager.placeOrder(confirmedOrder)
            cartManager.clearCart()
            
            self.confirmedOrder = confirmedOrder
            showingOrderConfirmation = true
            
        case .failure(let error):
            paymentErrorMessage = error.localizedDescription
            showingPaymentError = true
        }
    }
}

struct PaymentMethodRow: View {
    let paymentMethod: PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: paymentMethod.icon)
                    .font(.title3)
                    .foregroundColor(.brown)
                    .frame(width: 30)
                
                Text(paymentMethod.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.brown)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Apple Pay Delegate

private class ApplePayDelegate: NSObject, PKPaymentAuthorizationControllerDelegate {
    let paymentService: PaymentService
    let order: Order
    let completion: (Result<String, PaymentError>) -> Void
    
    init(
        paymentService: PaymentService,
        order: Order,
        completion: @escaping (Result<String, PaymentError>) -> Void
    ) {
        self.paymentService = paymentService
        self.order = order
        self.completion = completion
    }
    
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        paymentService.processApplePayPayment(payment: payment, for: order) { result in
            switch result {
            case .success:
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                self.completion(result)
            case .failure:
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                self.completion(result)
            }
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CartManager())
        .environmentObject(OrderManager())
        .environmentObject(AuthenticationManager())
        .environmentObject(CoffeeShopService())
}