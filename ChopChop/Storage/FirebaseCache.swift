import Foundation

class FirebaseCache {

    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    let userCache = Cache<String, User>()
    let imageCache = Cache<String, Data>()

}

 extension FirebaseCache {
    static let shared = makeShared()

    private static func makeShared() -> FirebaseCache {
        FirebaseCache()
    }
 }
