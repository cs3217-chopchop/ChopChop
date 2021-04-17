import Foundation

class ChopChopCache {

    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    let userCache = Cache<String, User>()
    var onlineRecipeImageCache = [String: Data]() // not using cache because Data cannot conform to CachableEntity

}

 extension ChopChopCache {
    static let shared = makeShared()

    private static func makeShared() -> ChopChopCache {
        ChopChopCache()
    }
 }
