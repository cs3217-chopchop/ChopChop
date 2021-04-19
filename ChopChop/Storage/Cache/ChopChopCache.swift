import Foundation

class ChopChopCache {

    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    let userCache = Cache<String, User>()
    let onlineRecipeImageCache = Cache<String, CachableData>()

}

 extension ChopChopCache {
    static let shared = makeShared()

    private static func makeShared() -> ChopChopCache {
        ChopChopCache()
    }
 }
