import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    
    func loadCurrentUser() {
        if let authUser = AuthService.shared.currentUser() {
            user = User(id: authUser.id, email: authUser.email, displayName: nil)
        }
    }
}


