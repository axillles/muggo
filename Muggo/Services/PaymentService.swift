//
//  PaymentService.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import PassKit

class PaymentService: ObservableObject {
    @Published var isProcessingPayment = false
    
    // MARK: - Apple Pay Support
    
    func canMakePayments() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments()
    }
    
    func canMakePaymentsUsingNetworks() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: [.visa, .masterCard, .amex, .discover]
        )
    }
    
    func createApplePayRequest(for order: Order) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = "merchant.com.yourcompany.muggo" // You'll need to register this
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = .capability3DS
        
        // Create payment summary items
        var paymentItems: [PKPaymentSummaryItem] = []
        
        for item in order.items {
            let paymentItem = PKPaymentSummaryItem(
                label: "\(item.quantity)x \(item.menuItem.name)",
                amount: NSDecimalNumber(value: item.totalPrice)
            )
            paymentItems.append(paymentItem)
        }
        
        // Add tax
        if order.tax > 0 {
            let taxItem = PKPaymentSummaryItem(
                label: "Tax",
                amount: NSDecimalNumber(value: order.tax)
            )
            paymentItems.append(taxItem)
        }
        
        // Add tip
        if order.tip > 0 {
            let tipItem = PKPaymentSummaryItem(
                label: "Tip",
                amount: NSDecimalNumber(value: order.tip)
            )
            paymentItems.append(tipItem)
        }
        
        // Total
        let totalItem = PKPaymentSummaryItem(
            label: "Muggo",
            amount: NSDecimalNumber(value: order.total)
        )
        paymentItems.append(totalItem)
        
        request.paymentSummaryItems = paymentItems
        
        return request
    }
    
    // MARK: - Payment Processing
    
    func processPayment(
        for order: Order,
        paymentMethod: PaymentMethod,
        completion: @escaping (Result<String, PaymentError>) -> Void
    ) {
        DispatchQueue.main.async {
            self.isProcessingPayment = true
        }
        
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                
                // Mock payment processing - in real app this would call a payment processor
                let success = Bool.random() || true // Force success for demo
                
                if success {
                    let transactionId = UUID().uuidString
                    completion(.success(transactionId))
                } else {
                    completion(.failure(.processingFailed))
                }
            }
        }
    }
    
    func processApplePayPayment(
        payment: PKPayment,
        for order: Order,
        completion: @escaping (Result<String, PaymentError>) -> Void
    ) {
        DispatchQueue.main.async {
            self.isProcessingPayment = true
        }
        
        // In a real app, you would send the payment token to your server
        // which would then process it with a payment processor like Stripe
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                let transactionId = UUID().uuidString
                completion(.success(transactionId))
            }
        }
    }
}

// MARK: - Payment Errors

enum PaymentError: Error, LocalizedError {
    case unsupportedPaymentMethod
    case processingFailed
    case insufficientFunds
    case networkError
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .unsupportedPaymentMethod:
            return "Payment method not supported"
        case .processingFailed:
            return "Payment processing failed"
        case .insufficientFunds:
            return "Insufficient funds"
        case .networkError:
            return "Network error occurred"
        case .cancelled:
            return "Payment was cancelled"
        }
    }
}