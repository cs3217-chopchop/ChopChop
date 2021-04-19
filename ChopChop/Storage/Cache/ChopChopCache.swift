import Foundation

/// Holds all the entities in the app's cache that have been fetched from firebase
struct ChopChopCache {
    /// Cache that is a dictionary of OnlineRecipe ids to OnlineRecipes
    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    /// Cache that is a dictionary of user ids to Users
    let userCache = Cache<String, User>()
    /// Cache that is a dictionary of online recipe image ids to CachableData
    let onlineRecipeImageCache = Cache<String, CachableData>()
}

 extension ChopChopCache {
    static let shared = makeShared()

    private static func makeShared() -> ChopChopCache {
        ChopChopCache()
    }
 }
