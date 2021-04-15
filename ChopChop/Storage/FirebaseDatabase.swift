import Firebase
import Combine

struct FirebaseDatabase {
    private let recipePath: String = "recipes (chrystal test)" // TODO change
    private let recipeInfoPath: String = "recipeInfos"
    private let userPath: String = "users (chrystal test)"
    private let userInfoPath: String = "userInfos"
    private let db = Firestore.firestore()

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

    func addRecipeRating(onlineRecipeId: String, rating: RecipeRating, completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        let recipeRef = db.collection(recipePath).document(onlineRecipeId)
        batch.updateData(["ratings": FieldValue.arrayUnion([rating.asDict])], forDocument: recipeRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(onlineRecipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoRef)

        batch.commit { err in
            completion(err)
        }
    }

    func updateRecipeRating(recipeId: String, oldRating: RecipeRating, newRating: RecipeRating, completion: @escaping (Error?) -> Void) {
        let docRef = db.collection(recipePath).document(recipeId)
        let recipeInfoDocRef = db.collection(recipeInfoPath).document(recipeId)

        let batch = db.batch()
        batch.updateData(["ratings": FieldValue.arrayRemove([oldRating.asDict])], forDocument: docRef)
        batch.updateData(["ratings": FieldValue.arrayUnion([newRating.asDict])], forDocument: docRef)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoDocRef)
        batch.commit { err in
            completion(err)
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

    func addUser(user: UserRecord) throws -> String {
        let userRef = db.collection(userPath).document()
        let batch = db.batch()
        try batch.setData(from: user, forDocument: userRef)

        let userInfo = try UserInfoRecord(id: userRef.documentID, name: user.name) // will it become populated?
        let userInfoRef = db.collection(userInfoPath).document(userRef.documentID)
        try batch.setData(from: userInfo, forDocument: userInfoRef)

        batch.commit()
        return userRef.documentID
    }

    func addFollowee(userId: String, followeeId: String, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection(userPath).document(userId)
        let batch = db.batch()
        batch.updateData(["followees": FieldValue.arrayUnion([followeeId])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)
        batch.commit { err in
            completion(err)
        }
    }

    // MARK: - FirebaseDatabase: Delete

    func removeRecipe(recipeId: String, completion: @escaping (Error?) -> Void) throws {
        let batch = db.batch()
        let recipeDocRef = db.collection(recipePath).document(recipeId)
        batch.deleteDocument(recipeDocRef)

        let recipeInfoDocRef = db.collection(recipeInfoPath).document(recipeId)
        batch.deleteDocument(recipeInfoDocRef)

        batch.commit { err in
            completion(err)
        }
    }

    func removeRecipeRating(onlineRecipeId: String, rating: RecipeRating, completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        let recipeRef = db.collection(recipePath).document(onlineRecipeId)
        batch.updateData(["ratings": FieldValue.arrayRemove([rating.asDict])], forDocument: recipeRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(onlineRecipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoRef)

        batch.commit { err in
            completion(err)
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

    func removeFollowee(userId: String, followeeId: String, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection(userPath).document(userId)
        let batch = db.batch()
        batch.updateData(["followees": FieldValue.arrayRemove([followeeId])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)
        batch.commit { err in
            completion(err)
        }
    }

    // MARK: - FirebaseDatabase: Read

    func fetchUserInfoById(userId: String, completion: @escaping (UserInfoRecord?, Error?) -> Void) {
        db.collection(userInfoPath).document(userId).getDocument { document, err in
            guard let userInfo = try? document?.data(as: UserInfoRecord.self) else {
                assertionFailure("Should have document")
                completion(nil, err)
                return
            }
            completion(userInfo, nil)
            // dont update userInfoCache because updatedAt will be incorrectly too recent
        }

    }

    // TODO test ALOT
    func fetchRecipeInfosByUsers(userIds: [String], completion: @escaping ([String: OnlineRecipeInfoRecord], Error?) -> Void) {

        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allOnlineRecipeInfoRecords = [String : OnlineRecipeInfoRecord]()

        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(recipeInfoPath).whereField("creator", in: range).getDocuments { snapshot, err in
                guard let recipeInfoRecords = (snapshot?.documents.compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }) else {
                    completion(allOnlineRecipeInfoRecords, err)
                }

                for recipeInfo in recipeInfoRecords {
                    guard let id = recipeInfo.id else {
                        continue
                    }
                    allOnlineRecipeInfoRecords[id] = recipeInfo
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(allOnlineRecipeInfoRecords, nil)
        }
    }

    func fetchOnlineRecipes(ids: [String], completion: @escaping ([OnlineRecipeRecord], Error?) -> Void) {

        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allOnlineRecipeRecords: [OnlineRecipeRecord] = []

        let queryLimit = QueryLimiter(max: ids.count)
        while queryLimit.hasNext {
            let range = [] + ids[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(recipePath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                guard let recipeRecords = (snapshot?.documents.compactMap { try? $0.data(as: OnlineRecipeRecord.self) }) else {
                    completion([], err)
                }

                allOnlineRecipeRecords.append(contentsOf: recipeRecords)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(allOnlineRecipeRecords, nil)
        }
    }

    func fetchOnlineRecipeInfosHelper(snapshot: QuerySnapshot?, error: Error?,
                                      completion: @escaping ([OnlineRecipeInfoRecord], Error?) -> Void) {
        guard let recipeInfoRecords = (snapshot?.documents.compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }) else {
            completion([], error)
        }
        completion(recipeInfoRecords, nil)
    }

    // TODO test ALOT
    func fetchRecipesByUsers(userIds: [String], completion: @escaping ([OnlineRecipeRecord], Error?) -> Void) {

        // recipeInfos of 10 users -> recipes of 10 recipeInfos
        guard !userIds.isEmpty else {
            completion([], nil)
            return
        }

        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            db.collection(recipeInfoPath).whereField("creator", in: range).getDocuments { snapshot, err in
                fetchOnlineRecipeHelper(snapshot: snapshot, error: err) {

                }
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
    func fetchAllUserInfos(completion: @escaping ([UserInfoRecord], Error?) -> Void) {
        db.collection(userInfoPath).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                assertionFailure("No user documents")
                return
            }

            var userInfos: [UserInfoRecord] = []
            for document in documents {
                guard let userInfo = try? document.data(as: UserInfoRecord.self), let userId = userInfo.id else {
                    continue
                }
                userInfos.append(userInfo)
                cache.userInfoCache.insert(userInfo, forKey: userId)
            }
            completion(userInfos, nil)
        }
    }

    func fetchOnlineRecipe(id: String, completion: @escaping (OnlineRecipeRecord?, Error?) -> Void) {
        db.collection(recipePath).document(id).getDocument { snapshot, err in
            guard let recipeRecord = try? snapshot?.data(as: OnlineRecipeRecord.self) else {
                    completion(nil, err)
                }
                completion(recipeRecord, nil)
        }
    }

    func fetchOnlineRecipeInfo(id: String, completion: @escaping (OnlineRecipeInfoRecord?, Error?) -> Void) {
        db.collection(recipeInfoPath).document(id).getDocument { snapshot, err in
            guard let recipeInfoRecord = try? snapshot?.data(as: OnlineRecipeInfoRecord.self) else {
                completion(nil, err)
                assertionFailure("Should have recipeInfo")
                return
            }
            completion(recipeInfoRecord, nil)
        }
    }

    func fetchOnlineRecipeInfo(onlineRecipeId: String, completion: @escaping (OnlineRecipeInfoRecord?, Error?) -> Void) {
        db.collection(recipeInfoPath).document(onlineRecipeId).getDocument { snapshot, err in
                guard let recipeInfo = try? snapshot?.data(as: OnlineRecipeInfoRecord.self) else {
                    completion(nil, err)
                    return
                }
                completion(recipeInfo, nil)
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
                                         completion: @escaping ([OnlineRecipeInfoRecord], Error?) -> Void) {
        guard let documents = snapshot?.documents else {
            completion([], error)
            return
        }

        // to find out which recipes to fetch
        var recipeIdsToFetch: [String] = []

        let recipeInfoRecords = documents.compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }
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

    private func shouldFetchUser(userInfo: UserInfoRecord) -> Bool {
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

// to pass around, like a shared memory
class DictionaryWrapper<T> {
    var entities = [String: T]()
}
