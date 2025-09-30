import Foundation
import PassKit

enum PaymentError: Error {
    case notSupported
    case cancelled
}

final class PaymentService: NSObject {
    static let shared = PaymentService()
    private override init() {}
    
    func canUseApplePay() -> Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }
}


