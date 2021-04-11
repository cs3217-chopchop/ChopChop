import Firebase
import Combine

struct FirebaseDatabase {
    private let recipePath: String = "recipes"
    private let recipeInfoPath: String = "recipeInfos"
    private let userPath: String = "users"
    private let userInfoPath: String = "userInfos"
    private let db = Firestore.firestore()
    private let cache: FirebaseCache

    init(cache: FirebaseCache) {
        self.cache = cache
    }

    func addRecipe(recipe: OnlineRecipeRecord) throws -> String {
        do {
            let recipeDocRef = db.collection(recipePath).document()
            let batch = db.batch()
            try batch.setData(from: recipe, forDocument: recipeDocRef)

            let recipeInfo = OnlineRecipeInfoRecord(id: recipeDocRef.documentID, creator: recipe.creator)
            let recipeInfoRef = db.collection(recipeInfoPath).document(recipeDocRef.documentID)
            try batch.setData(from: recipeInfo, forDocument: recipeInfoRef)

            batch.commit()
            return recipeDocRef.documentID
        } catch {
            throw FirebaseError.addRecipeError(message: "Unable to add recipe: \(error.localizedDescription)")
        }
    }

    func removeRecipe(recipeId: String) throws {
        let batch = db.batch()
        let recipeDocRef = db.collection(recipePath).document()
        batch.deleteDocument(recipeDocRef)

        let recipeInfoDocRef = db.collection(recipeInfoPath).document()
        batch.deleteDocument(recipeInfoDocRef)
        batch.commit()
    }

    func updateRecipeDetails(recipe: OnlineRecipeRecord) {
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

    func fetchRecipesByUsers(userIds: [String], completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        // recipeInfos of 10 users -> recipes of 10 recipeInfos

        var allRecipeInfoRecords = DictionaryWrapper()

        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            db.collection(recipeInfoPath).whereField("userId", in: range).getDocuments { snapshot, err in
                fetchOnlineRecipeHelper(snapshot: snapshot, error: err, completion: completion, allRecipeInfoRecords: allRecipeInfoRecords)
            }
        }
    }

    func fetchAllRecipes(completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        var allRecipeInfoRecords = DictionaryWrapper()

        db.collection(recipeInfoPath).getDocuments { snapshot, err in
            fetchOnlineRecipeHelper(snapshot: snapshot, error: err, completion: completion, allRecipeInfoRecords: allRecipeInfoRecords)
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
            if shouldFetchOnlineRecipe(onlineRecipeId: recipeInfoId, recipeInfoRecord: recipeInfoRecord) {
                recipeIdsToFetch.append(recipeInfoId)
            }
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
                }

                let recipes = allRecipeInfoRecords.dictionary.compactMap { cache.onlineRecipeCache[$0.value.id ?? ""] }
                completion(recipes, nil)
            }
        }
    }

    func fetchAllUsers(completion: @escaping ([UserInfo], Error?) -> Void) {
        db.collection(userInfoPath).getDocuments { snapshot, err in
            guard let userIds = (snapshot?.documents.map { $0.documentID }) else {
                completion([], err)
                assertionFailure("Should have user ids")
                return
            }
            fetchUserHelper(snapshot: snapshot, error: err, completion: completion, userIds: userIds)
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

    func fetchUsers(userIds: [String], completion: @escaping ([UserInfo], Error?) -> Void) {
        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            db.collection(userPath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                fetchUserHelper(snapshot: snapshot, error: err, completion: completion, userIds: userIds)
            }
        }
    }

    private func fetchUserHelper(snapshot: QuerySnapshot?, error: Error?,
                                 completion: @escaping ([UserInfo], Error?) -> Void, userIds: [String]) {
        guard let documents = snapshot?.documents else {
            completion([], error)
            assertionFailure("Should have user ids")
            return
        }
        for document in documents {
            guard let user = try? document.data(as: UserInfo.self), let userId = user.id else {
                completion([], error)
                continue
            }

            // TODO fetch from actual user array
            cache.userCache.insert(user, forKey: userId)
        }

        let users = userIds.compactMap { cache.userCache[$0] }
        completion(users, nil)
    }

    func updateRecipeRating(recipeId: String, recipeRating: RecipeRating) {
        let docRef = db.collection(recipePath).document(recipeId)
        let recipeInfoDocRef = db.collection(recipeInfoPath).document(recipeId)

        let batch = db.batch()
        batch.updateData(["ratings": FieldValue.arrayRemove([recipeRating.asDict])], forDocument: docRef)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoDocRef)
        batch.commit()
    }

    func updateUserRating(userId: String, userRating: UserRating) {
        db.collection(userPath).document(userId).updateData(["ratings": FieldValue.arrayRemove([userRating.asDict])])
    }

    func fetchOnlineRecipeById(onlineRecipeId: String, completion: @escaping (OnlineRecipe?, Error?) -> Void) {

        db.collection(recipeInfoPath).document(onlineRecipeId).getDocument { snapshot, err in
            guard let recipeInfoRecord = try? snapshot?.data(as: OnlineRecipeInfoRecord.self) else {
                completion(nil, err)
                assertionFailure("Should have recipeInfo")
                return
            }

            guard shouldFetchOnlineRecipe(onlineRecipeId: onlineRecipeId, recipeInfoRecord: recipeInfoRecord) else {
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
                    assertionFailure("Should be able to convert")
                    return
                }

                cache.onlineRecipeCache.insert(recipe, forKey: recipe.id)
                completion(recipe, nil)
            }

        }
    }

    func addRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        let batch = db.batch()
        let recipeRef = db.collection(recipePath).document(onlineRecipeId)
        batch.updateData(["ratings": FieldValue.arrayUnion([rating.asDict])], forDocument: recipeRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(onlineRecipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoRef)

        batch.commit()
    }

    func removeRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        let batch = db.batch()
        let recipeRef = db.collection(recipePath).document(onlineRecipeId)
        batch.updateData(["ratings": FieldValue.arrayRemove([rating.asDict])], forDocument: recipeRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(onlineRecipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoRef)

        batch.commit()
    }

    func addUserRecipeRating(userId: String, rating: UserRating) {
        db.collection(userPath).document(userId)
            .updateData(["ratings": FieldValue.arrayUnion([rating.asDict])])
    }

    func removeUserRecipeRating(userId: String, rating: UserRating) {
        db.collection(userPath).document(userId)
            .updateData(["ratings": FieldValue.arrayRemove([rating.asDict])])
    }

    func addUser(user: User) throws -> String {
        try db.collection(userPath).addDocument(from: user).documentID
    }

    func removeUser(userId: String) throws {
        db.collection(userPath).document(userId).delete()
    }

    func listenUserById(userId: String, onChange: @escaping (User) -> Void) {
        db.collection(userPath).document(userId)
            .addSnapshotListener { documentSnapshot, _ in
                guard let user = try? documentSnapshot?.data(as: User.self) else {
                    return
              }
                onChange(user)
            }

    }

    func fetchUserById(userId: String, completion: @escaping (UserInfo?, Error?) -> Void) {
        // TODO check user not expired
        if let user = cache.userCache[userId] {
            completion(user, nil)
        }

        db.collection(userPath).document(userId).getDocument { document, err in
            guard let document = document, document.exists, let user = try? document.data(as: User.self) else {
                completion(nil, err)
                assertionFailure("Should have document")
                return
            }
            cache.userCache.insert(user, forKey: userId)
            completion(user, nil)
        }
    }

    func addFollowee(userId: String, followeeId: String) {
        db.collection(userPath).document(userId).updateData(["followees": FieldValue.arrayUnion([followeeId])])
    }

    func removeFollowee(userId: String, followeeId: String) {
        db.collection(userPath).document(userId).updateData(["followees": FieldValue.arrayRemove([followeeId])])
    }

    private func shouldFetchOnlineRecipe(onlineRecipeId: String, recipeInfoRecord: OnlineRecipeInfoRecord) -> Bool {
        guard let cachedCopy = cache.onlineRecipeCache[onlineRecipeId],
              let actualLastUpdatedAt = recipeInfoRecord.updatedAt,
              cachedCopy.updatedAt >= actualLastUpdatedAt else {
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
