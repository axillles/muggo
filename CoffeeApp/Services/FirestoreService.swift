import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
import FirebaseFirestoreSwift
#endif

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}
    
    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    #endif
    
    func fetchCoffeeShops() async throws -> [CoffeeShop] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await db.collection("coffee_shops").getDocuments()
        return try snapshot.documents.map { try $0.data(as: CoffeeShop.self) }
        #else
        return []
        #endif
    }
}


