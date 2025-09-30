import Foundation

#if canImport(FirebaseStorage)
import FirebaseStorage
#endif

final class StorageService {
    static let shared = StorageService()
    private init() {}
    
    func downloadURL(path: String) async throws -> URL {
        #if canImport(FirebaseStorage)
        let ref = Storage.storage().reference(withPath: path)
        return try await ref.downloadURL()
        #else
        throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "FirebaseStorage недоступен"])
        #endif
    }
}


