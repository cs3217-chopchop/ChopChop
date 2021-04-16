import Foundation

class FirebaseCache {

    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    let userCache = Cache<String, User>()
    var onlineRecipeImageCache = [String: Data]() // TODO Dont use NSCache, otherwise will evict images out when low on memory??

}

 extension FirebaseCache {
    static let shared = makeShared()

    private static func makeShared() -> FirebaseCache {
        FirebaseCache()
    }
 }
