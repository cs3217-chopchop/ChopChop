class FirebaseCache {

    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    let userCache = Cache<String, User>()

}

 extension FirebaseCache {
    static let shared = makeShared()

    private static func makeShared() -> FirebaseCache {
        FirebaseCache()
    }
 }
