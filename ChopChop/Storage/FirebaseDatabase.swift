import Firebase
import Combine

struct FirebaseDatabase {
    private let recipePath: String = "recipes (chrystal test)" // TODO change
    private let recipeInfoPath: String = "recipeInfos"
    private let userPath: String = "users (chrystal test)"
    private let userInfoPath: String = "userInfos"
    private let db = Firestore.firestore()
    private let cache: FirebaseCache

    init(cache: FirebaseCache) {
        self.cache = cache
    }

    // MARK: - FirebaseDatabase: Create/Update
    func addRecipe(recipe: OnlineRecipeRecord) throws -> String {
        let recipeDocRef = db.collection(recipePath).document()
        let batch = db.batch()
        try batch.setData(from: recipe, forDocument: recipeDocRef)

        let recipeInfo = OnlineRecipeInfoRecord(id: recipeDocRef.documentID, creator: recipe.creator)
        let recipeInfoRef = db.collection(recipeInfoPath).document(recipeDocRef.documentID)
        try batch.setData(from: recipeInfo, forDocument: recipeInfoRef)

        batch.commit()
        return recipeDocRef.documentID
    }

    func updateRecipe(recipe: OnlineRecipeRecord) {
        guard let recipeId = recipe.id else {
            fatalError("Recipe does not have reference to online Id.")
        }

        let batch = db.batch()
        let recipeDocRef = db.collection(recipePath).document(recipeId)
        batch.setData([
            "name": recipe.name,
            "creator": recipe.creator,
            "servings": recipe.servings,
            "difficulty": recipe.difficulty?.rawValue,
            "cuisine": recipe.cuisine,
            "steps": recipe.steps,
            "ingredients": recipe.ingredients.map({ $0.asDict })
        ], forDocument: recipeDocRef, merge: true)

        let recipeInfoDocRef = db.collection(recipeInfoPath).document(recipeId)
        batch.setData([
            "updatedAt": FieldValue.serverTimestamp()
        ], forDocument: recipeInfoDocRef, merge: true)

        batch.commit()
    }

    func addRecipeRating(onlineRecipeId: String, rating: RecipeRating, completion: @escaping () -> Void) {
        let batch = db.batch()
        let recipeRef = db.collection(recipePath).document(onlineRecipeId)
        batch.updateData(["ratings": FieldValue.arrayUnion([rating.asDict])], forDocument: recipeRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(onlineRecipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoRef)

        batch.commit { err in
            if let err = err {
                print("Could not update recipe") // can't throw errors from here
            } else {
                completion()
            }
        }
    }

    func updateRecipeRating(recipeId: String, oldRating: RecipeRating, newRating: RecipeRating, completion: @escaping () -> Void) {
        let docRef = db.collection(recipePath).document(recipeId)
        let recipeInfoDocRef = db.collection(recipeInfoPath).document(recipeId)

        let batch = db.batch()
        batch.updateData(["ratings": FieldValue.arrayRemove([oldRating.asDict])], forDocument: docRef)
        batch.updateData(["ratings": FieldValue.arrayUnion([newRating.asDict])], forDocument: docRef)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoDocRef)
        batch.commit { err in
            if let err = err {
                print("Could not update recipe") // can't throw errors from here
            } else {
                completion()
            }
        }
    }

    func addUserRecipeRating(userId: String, rating: UserRating) {
        let batch = db.batch()
        let userRef = db.collection(userPath).document(userId)
        batch.updateData(["ratings": FieldValue.arrayUnion([rating.asDict])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)

        batch.commit()
    }

    func updateUserRating(userId: String, oldRating: UserRating, newRating: UserRating) {
        let docRef = db.collection(userPath).document(userId)
        let userInfoDocRef = db.collection(userInfoPath).document(userId)
        let batch = db.batch()
        batch.updateData(["ratings": FieldValue.arrayRemove([oldRating.asDict])], forDocument: docRef)
        batch.updateData(["ratings": FieldValue.arrayUnion([newRating.asDict])], forDocument: docRef)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoDocRef)
        batch.commit()
    }

    func addUser(user: User) throws -> String {
        let userRef = db.collection(userPath).document()
        let batch = db.batch()
        try batch.setData(from: user, forDocument: userRef)

        let userInfo = try UserInfo(id: userRef.documentID, name: user.name) // will it become populated?
        let userInfoRef = db.collection(userInfoPath).document(userRef.documentID)
        try batch.setData(from: userInfo, forDocument: userInfoRef)

        batch.commit()
        return userRef.documentID
    }

    func addFollowee(userId: String, followeeId: String, completion: @escaping () -> Void) {
        let userRef = db.collection(userPath).document(userId)
        let batch = db.batch()
        batch.updateData(["followees": FieldValue.arrayUnion([followeeId])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)
        batch.commit { err in
            if let err = err {
                print("Could not add followee") // can't throw errors from here
            } else {
                completion()
            }
        }
    }

    // MARK: - FirebaseDatabase: Delete

    // TODO havent test
    func removeRecipe(recipeId: String, completion: @escaping () -> Void) throws {
        let batch = db.batch()
        let recipeDocRef = db.collection(recipePath).document()
        batch.deleteDocument(recipeDocRef)

        let recipeInfoDocRef = db.collection(recipeInfoPath).document()
        batch.deleteDocument(recipeInfoDocRef)

        batch.commit { err in
            if let err = err {
                print("Could not remove recipe") // can't throw errors from here
            } else {
                completion()
            }
        }

        cache.onlineRecipeCache.removeValue(forKey: recipeDocRef.documentID)
    }

    func removeRecipeRating(onlineRecipeId: String, rating: RecipeRating, completion: @escaping () -> Void) {
        let batch = db.batch()
        let recipeRef = db.collection(recipePath).document(onlineRecipeId)
        batch.updateData(["ratings": FieldValue.arrayRemove([rating.asDict])], forDocument: recipeRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(onlineRecipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoRef)

        batch.commit { err in
            if let err = err {
                print("Could not update recipe") // can't throw errors from here
            } else {
                completion()
            }
        }
    }

    func removeUserRecipeRating(userId: String, rating: UserRating) {
        let batch = db.batch()
        let userRef = db.collection(userPath).document(userId)
        batch.updateData(["ratings": FieldValue.arrayRemove([rating.asDict])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)

        batch.commit()
    }

    // not used
    func removeUser(userId: String) throws {
        let userRef = db.collection(userPath).document(userId)
        let batch = db.batch()
        batch.deleteDocument(userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.deleteDocument(userInfoRef)
        batch.commit()
    }

    func removeFollowee(userId: String, followeeId: String, completion: @escaping () -> Void) {
        let userRef = db.collection(userPath).document(userId)
        let batch = db.batch()
        batch.updateData(["followees": FieldValue.arrayRemove([followeeId])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)
        batch.commit { err in
            if let err = err {
                print("Could not remove followee") // can't throw errors from here
            } else {
                completion()
            }
        }
    }

    // MARK: - FirebaseDatabase: Read

    func fetchUserInfoById(userId: String, completion: @escaping (UserInfo?, Error?) -> Void) {
        db.collection(userInfoPath).document(userId).getDocument { document, err in
            guard let userInfo = try? document?.data(as: UserInfo.self) else {
                assertionFailure("Should have document")
                completion(nil, err)
                return
            }
            completion(userInfo, nil)
            // dont update userInfoCache because updatedAt will be incorrectly too recent
        }

    }

    // TODO test ALOT
    func fetchRecipesByUsers(userIds: [String], completion: @escaping ([OnlineRecipe], Error?) -> Void) {

        // recipeInfos of 10 users -> recipes of 10 recipeInfos
        guard !userIds.isEmpty else {
            completion([], nil)
            return
        }

        var allRecipeInfoRecords = DictionaryWrapper()

        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            db.collection(recipeInfoPath).whereField("creator", in: range).getDocuments { snapshot, err in
                fetchOnlineRecipeHelper(snapshot: snapshot, error: err, completion: completion, allRecipeInfoRecords: allRecipeInfoRecords)
            }
        }
    }

    // TODO test ALOT
    func fetchAllRecipes(completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        var allRecipeInfoRecords = DictionaryWrapper()

        db.collection(recipeInfoPath).getDocuments { snapshot, err in
            fetchOnlineRecipeHelper(snapshot: snapshot, error: err, completion: completion, allRecipeInfoRecords: allRecipeInfoRecords)
        }
    }

    // used for users page
    func fetchAllUserInfos(completion: @escaping ([UserInfo], Error?) -> Void) {
        db.collection(userInfoPath).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                assertionFailure("No user documents")
                return
            }

            var userInfos: [UserInfo] = []
            for document in documents {
                guard let userInfo = try? document.data(as: UserInfo.self), let userId = userInfo.id else {
                    continue
                }
                userInfos.append(userInfo)
                cache.userInfoCache.insert(userInfo, forKey: userId)
            }
            completion(userInfos, nil)
        }
    }

//    func fetchFolloweesId(userId: String) -> AnyPublisher<[String], Error> {
//        db.collection(userPath).document(userId)
//            .publisher()
//            .map({
//                try? $0.data(as: User.self)
//            })
//            .map({
//                $0?.followees ?? []
//            })
//            .eraseToAnyPublisher()
//    }

    func fetchOnlineRecipeById(onlineRecipeId: String, completion: @escaping (OnlineRecipe?, Error?) -> Void) {
        db.collection(recipeInfoPath).document(onlineRecipeId).getDocument { snapshot, err in
            guard let recipeInfoRecord = try? snapshot?.data(as: OnlineRecipeInfoRecord.self) else {
                completion(nil, err)
                assertionFailure("Should have recipeInfo")
                return
            }

            guard shouldFetchOnlineRecipe(recipeInfoRecord: recipeInfoRecord) else {
                guard let cachedCopy = cache.onlineRecipeCache[onlineRecipeId] else {
                    completion(nil, err)
                    assertionFailure("Should have cached copy")
                    return
                }
                completion(cachedCopy, nil)
                return
            }

            db.collection(recipePath).document(onlineRecipeId).getDocument { snapshot, err in
                guard let recipeRecord = try? snapshot?.data(as: OnlineRecipeRecord.self),
                      let recipe = try? OnlineRecipe(from: recipeRecord, info: recipeInfoRecord) else {
                    completion(nil, err)
//                    assertionFailure("Should be able to convert")
                    return
                }

                cache.onlineRecipeCache.insert(recipe, forKey: recipe.id)
                completion(recipe, nil)
            }

        }
    }

    // not used
    func fetchUserById(userId: String, completion: @escaping (User?, Error?) -> Void) {
        db.collection(userInfoPath).document(userId).getDocument { document, err in
            guard let userInfo = try? document?.data(as: UserInfo.self) else {
                assertionFailure("Should have document")
                completion(nil, err)
                return
            }

            guard shouldFetchUser(userInfo: userInfo) else {
                guard let cacheCopy = cache.userCache[userId] else {
                    assertionFailure("Does not exist in cache")
                    return
                }
                completion(cacheCopy, nil)
                return
            }

            db.collection(userPath).document(userId).getDocument { document, err in
                guard let document = document, document.exists, let user = try? document.data(as: User.self) else {
                    completion(nil, err)
                    assertionFailure("Should have document")
                    return
                }
                cache.userCache.insert(user, forKey: userId)
                cache.userInfoCache.insert(userInfo, forKey: userId)
                completion(user, nil)
            }

        }

    }

    // not used
    func fetchAllUsers(completion: @escaping ([User], Error?) -> Void) {
        db.collection(userInfoPath).getDocuments { snapshot, err in
            guard let userIds = (snapshot?.documents.map { $0.documentID }) else {
                assertionFailure("No user documents")
                completion([], err)
                return
            }

            fetchUserHelper(snapshot: snapshot, error: err, completion: completion, userIds: userIds)
        }
     }

    // not used
    func fetchUsers(userIds: [String], completion: @escaping ([User], Error?) -> Void) {
        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            db.collection(userInfoPath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                fetchUserHelper(snapshot: snapshot, error: err, completion: completion, userIds: userIds)
            }
        }
    }

    // MARK: - FirebaseDatabase: Listeners

    func listenUserById(userId: String, onChange: @escaping (User) -> Void) {
        db.collection(userPath).document(userId)
            .addSnapshotListener { documentSnapshot, _ in
                guard let user = try? documentSnapshot?.data(as: User.self) else {
                    assertionFailure("No user")
                    return
                }
                onChange(user)
            }
    }

    private func fetchOnlineRecipeHelper(snapshot: QuerySnapshot?, error: Error?,
                                         completion: @escaping ([OnlineRecipe], Error?) -> Void, allRecipeInfoRecords: DictionaryWrapper) {
        guard let documents = snapshot?.documents else {
            completion([], error)
            return
        }

        // to find out which recipes to fetch
        var recipeIdsToFetch: [String] = []

        let recipeInfoRecords = documents.compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }
        recipeInfoRecords.forEach { allRecipeInfoRecords.dictionary[$0.id] = $0 }

        for recipeInfoRecord in recipeInfoRecords {
            guard let recipeInfoId = recipeInfoRecord.id else {
                assertionFailure("Should have an id")
                continue
            }
            if shouldFetchOnlineRecipe(recipeInfoRecord: recipeInfoRecord) {
                recipeIdsToFetch.append(recipeInfoId)
            }
        }

        guard !recipeIdsToFetch.isEmpty else {
            let recipes = allRecipeInfoRecords.dictionary.compactMap { cache.onlineRecipeCache[$0.value.id ?? ""] }
            completion(recipes, nil)
            return
        }

        // to update cache with fetched recipes
        let totalRecipeCount = recipeIdsToFetch.count
        let queryLimit = QueryLimiter(max: totalRecipeCount)
        while queryLimit.hasNext {
            let range = [] + recipeIdsToFetch[queryLimit.current..<queryLimit.next()]
            db.collection(recipePath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                guard let documents = snapshot?.documents else {
                    completion([], err)
                    assertionFailure("Should get some documents")
                    return
                }

                for document in documents {
                    guard let recipeRecord = try? document.data(as: OnlineRecipeRecord.self),
                          let recipeInfoRecord = allRecipeInfoRecords.dictionary[recipeRecord.id],
                          let recipe = try? OnlineRecipe(from: recipeRecord, info: recipeInfoRecord)
                          else {
                        completion([], err)
                        continue
                    }
                    cache.onlineRecipeCache.insert(recipe, forKey: recipe.id)
                    print(recipe.name)
                }

                let recipes = allRecipeInfoRecords.dictionary.compactMap { cache.onlineRecipeCache[$0.value.id ?? ""] }
                completion(recipes, nil)
            }
        }
    }

    // not used
    private func fetchUserHelper(snapshot: QuerySnapshot?, error: Error?,
                                 completion: @escaping ([User], Error?) -> Void, userIds: [String]) {
        guard let documents = snapshot?.documents else {
            completion([], error)
            assertionFailure("Should have user ids")
            return
        }

        var shouldFetchUserIds: [String] = []

        for document in documents {
            guard let user = try? document.data(as: UserInfo.self), let userId = user.id else {
                completion([], error)
                continue
            }
            cache.userInfoCache.insert(user, forKey: userId)

            if shouldFetchUser(userInfo: user) {
                shouldFetchUserIds.append(userId)
            }
        }

        let queryLimit = QueryLimiter(max: shouldFetchUserIds.count)
        while queryLimit.hasNext {
            let range = [] + shouldFetchUserIds[queryLimit.current..<queryLimit.next()]
            db.collection(userPath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else {
                    completion([], error)
                    assertionFailure("Should have user ids")
                    return
                }

                for document in documents {
                    guard let user = try? document.data(as: User.self), let userId = user.id else {
                        completion([], error)
                        continue
                    }
                    cache.userCache.insert(user, forKey: userId)
                }

                let users = userIds.compactMap { cache.userCache[$0] }
                completion(users, nil)
            }
        }
    }

    private func shouldFetchOnlineRecipe(recipeInfoRecord: OnlineRecipeInfoRecord) -> Bool {
        guard let onlineRecipeId = recipeInfoRecord.id,
              let cachedCopy = cache.onlineRecipeCache[onlineRecipeId],
              let actualLastUpdatedAt = recipeInfoRecord.updatedAt,
              cachedCopy.updatedAt >= actualLastUpdatedAt else {
            return true
        }
        return false
    }

    private func shouldFetchUser(userInfo: UserInfo) -> Bool {
        guard let userId = userInfo.id,
              let cachedCopy = cache.userInfoCache[userId],
              let actualLastUpdatedAt = userInfo.updatedAt,
              let cachedLastUpdatedAt = cachedCopy.updatedAt,
              cachedLastUpdatedAt >= actualLastUpdatedAt else {
            return true
        }
        return false
    }
}

enum FirebaseError: Error {
    case addRecipeError(message: String), removeRecipeError(message: String),
         updateRecipeError(message: String), fetchRecipeError(message: String),
         addUserError(message: String), removeUserError(message: String), addRatingError(message: String)
}

class QueryLimiter {
    private(set) var current = 0
    private let queryLimit = 10
    private let max: Int

    init(max: Int) {
        self.max = max
    }

    var hasNext: Bool {
        current < max
    }

    func next() -> Int {
        if current + queryLimit < max {
            current += queryLimit
        } else {
            current = max
        }
        return current
    }
}

class DictionaryWrapper {
    var dictionary = [String?: OnlineRecipeInfoRecord]()
}
