class FirebaseCache {

    let onlineRecipeCache = Cache<String, OnlineRecipe>()
    let userCache = Cache<String, UserInfo>()
//    let userInfoCache = Cache<String, UserInfo>()

}

 extension FirebaseCache {
    static let shared = makeShared()

    private static func makeShared() -> FirebaseCache {
        FirebaseCache()
    }
 }
