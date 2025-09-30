import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

enum FirebaseManager {
    static func configureIfNeeded() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif
    }
}


