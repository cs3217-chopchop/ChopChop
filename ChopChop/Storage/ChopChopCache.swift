import Foundation

class ChopChopCache {

    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    let userCache = Cache<String, User>()
    var onlineRecipeImageCache = [String: Data]() // TODO Dont use NSCache, otherwise will evict images out when low on memory??

}

 extension ChopChopCache {
    static let shared = makeShared()

    private static func makeShared() -> ChopChopCache {
        ChopChopCache()
    }
 }
