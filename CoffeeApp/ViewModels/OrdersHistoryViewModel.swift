import Foundation

final class OrdersHistoryViewModel: ObservableObject {
    @Published var completedOrders: [Order] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetch(for userId: String) {
        isLoading = true
        Task {
            do {
                let orders = try await SupabaseService.shared.fetchOrders(for: userId)
                let filtered = orders.filter { $0.status == .completed }
                await MainActor.run {
                    self.completedOrders = filtered
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}


