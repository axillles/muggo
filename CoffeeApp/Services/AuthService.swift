import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    struct AuthUser: Identifiable, Codable {
        let id: String
        let email: String?
    }
    
    func currentUser() -> AuthUser? {
        #if canImport(FirebaseAuth)
        if let user = Auth.auth().currentUser {
            return AuthUser(id: user.uid, email: user.email)
        }
        #endif
        return nil
    }
    
    func signInAnonymously() async throws -> AuthUser {
        #if canImport(FirebaseAuth)
        let result = try await Auth.auth().signInAnonymously()
        let user = result.user
        return AuthUser(id: user.uid, email: user.email)
        #else
        throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "FirebaseAuth недоступен"])
        #endif
    }
}


