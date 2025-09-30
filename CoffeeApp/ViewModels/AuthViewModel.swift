import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    func signInAnonymously() {
        isLoading = true
        Task {
            do {
                let authUser = try await AuthService.shared.signInAnonymously()
                await MainActor.run {
                    self.user = User(id: authUser.id, email: authUser.email, displayName: nil)
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


