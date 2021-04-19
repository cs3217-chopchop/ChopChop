import Firebase
import Combine

struct FirebaseDatabase {
    private let recipePath: String = "recipes (chrystal test)" // TODO change
    private let recipeInfoPath: String = "recipeInfos"
    private let userPath: String = "users (chrystal test)"
    private let userInfoPath: String = "userInfos"
    private let db = Firestore.firestore()

    // MARK: - FirebaseDatabase: Create/Update
    func addOnlineRecipe(recipe: OnlineRecipeRecord, completion: @escaping (Error?) -> Void) throws -> String {
        let recipeDocRef = db.collection(recipePath).document()
        let batch = db.batch()
        try batch.setData(from: recipe, forDocument: recipeDocRef)

        let recipeInfo = OnlineRecipeInfoRecord(id: recipeDocRef.documentID, creator: recipe.creator)
        let recipeInfoRef = db.collection(recipeInfoPath).document(recipeDocRef.documentID)
        try batch.setData(from: recipeInfo, forDocument: recipeInfoRef)

        batch.commit { err in
            completion(err)
        }
        return recipeDocRef.documentID
    }

    func updateOnlineRecipe(recipe: OnlineRecipeRecord, isImageUploadedAlready: Bool?, completion: @escaping (Error?) -> Void) {
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
        if let isImageUploadedAlready = isImageUploadedAlready {
            if isImageUploadedAlready {
                batch.setData([
                    "updatedAt": FieldValue.serverTimestamp()
                ], forDocument: recipeInfoDocRef, merge: true)
            } else {
                batch.setData([
                    "updatedAt": FieldValue.serverTimestamp(),
                    "imageUpdatedAt": FieldValue.serverTimestamp()
                ], forDocument: recipeInfoDocRef, merge: true)
            }
        } else {
            batch.setData([
                "updatedAt": FieldValue.serverTimestamp(),
                "imageUpdatedAt": nil
            ], forDocument: recipeInfoDocRef, merge: true)
        }

        batch.commit { err in
            completion(err)
        }
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

    func updateRecipeRating(recipeId: String, oldRating: RecipeRating, newRating: RecipeRating,
                            completion: @escaping (Error?) -> Void) {
        let docRef = db.collection(recipePath).document(recipeId)

        let batch = db.batch()
        batch.updateData(["ratings": FieldValue.arrayRemove([oldRating.asDict])], forDocument: docRef)
        batch.updateData(["ratings": FieldValue.arrayUnion([newRating.asDict])], forDocument: docRef)

        let recipeInfoDocRef = db.collection(recipeInfoPath).document(recipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoDocRef)

        batch.commit { err in
            completion(err)
        }
    }

    func addUserRecipeRating(userId: String, rating: UserRating, completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        let userRef = db.collection(userPath).document(userId)
        batch.updateData(["ratings": FieldValue.arrayUnion([rating.asDict])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)

        batch.commit { err in
            completion(err)
        }
    }

    func updateUserRating(userId: String, oldRating: UserRating, newRating: UserRating, completion: @escaping (Error?) -> Void) {
        let docRef = db.collection(userPath).document(userId)
        let userInfoDocRef = db.collection(userInfoPath).document(userId)
        let batch = db.batch()
        batch.updateData(["ratings": FieldValue.arrayRemove([oldRating.asDict])], forDocument: docRef)
        batch.updateData(["ratings": FieldValue.arrayUnion([newRating.asDict])], forDocument: docRef)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoDocRef)

        batch.commit { err in
            completion(err)
        }
    }

    func addUser(user: UserRecord, completion: @escaping (Error?) -> Void) throws -> String {
        let userRef = db.collection(userPath).document()
        let batch = db.batch()
        try batch.setData(from: user, forDocument: userRef)

        let userInfo = UserInfoRecord(id: userRef.documentID)
        let userInfoRef = db.collection(userInfoPath).document(userRef.documentID)
        try batch.setData(from: userInfo, forDocument: userInfoRef)

        batch.commit { err in
            completion(err)
        }
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

    func removeOnlineRecipe(recipeId: String, completion: @escaping (Error?) -> Void) throws {
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

    func removeUserRecipeRating(userId: String, rating: UserRating, completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        let userRef = db.collection(userPath).document(userId)
        batch.updateData(["ratings": FieldValue.arrayRemove([rating.asDict])], forDocument: userRef)

        let userInfoRef = db.collection(userInfoPath).document(userId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: userInfoRef)

        batch.commit { err in
            completion(err)
        }
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

    func fetchUserInfo(id: String, completion: @escaping (UserInfoRecord?, Error?) -> Void) {
        db.collection(userInfoPath).document(id).getDocument { document, err in
            guard let userInfo = try? document?.data(as: UserInfoRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(userInfo, nil)
        }
    }

    func fetchUser(id: String, completion: @escaping (UserRecord?, Error?) -> Void) {
        db.collection(userPath).document(id).getDocument { document, err in
            guard let user = try? document?.data(as: UserRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(user, nil)
        }
    }

    // TODO test ALOT
    func fetchOnlineRecipeInfos(userIds: [String], completion: @escaping ([String: OnlineRecipeInfoRecord], Error?) -> Void) {

        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allOnlineRecipeInfoRecords = [String: OnlineRecipeInfoRecord]()

        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(recipeInfoPath).whereField("creator", in: range).getDocuments { snapshot, err in
                guard let recipeInfoRecords = (snapshot?.documents.compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }), err == nil else {
                    completion(allOnlineRecipeInfoRecords, err)
                    dispatchGroup.leave()
                    return
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

    func fetchAllOnlineRecipeInfos(completion: @escaping ([String: OnlineRecipeInfoRecord], Error?) -> Void) {
        db.collection(recipeInfoPath).getDocuments { snapshot, err in
            var allOnlineRecipeInfoRecords = [String: OnlineRecipeInfoRecord]()

            guard let recipeInfoRecords = (snapshot?.documents.compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }), err == nil else {
                completion(allOnlineRecipeInfoRecords, err)
                return
            }

            for recipeInfo in recipeInfoRecords {
                guard let id = recipeInfo.id else {
                    continue
                }
                allOnlineRecipeInfoRecords[id] = recipeInfo
            }
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
                guard let recipeRecords = (snapshot?.documents.compactMap { try? $0.data(as: OnlineRecipeRecord.self) }), err == nil else {
                    completion([], err)
                    dispatchGroup.leave()
                    return
                }

                allOnlineRecipeRecords.append(contentsOf: recipeRecords)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(allOnlineRecipeRecords, nil)
        }
    }

    func fetchOnlineRecipe(id: String, completion: @escaping (OnlineRecipeRecord?, Error?) -> Void) {
        db.collection(recipePath).document(id).getDocument { snapshot, err in
            guard let recipeRecord = try? snapshot?.data(as: OnlineRecipeRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(recipeRecord, nil)
        }
    }

    func fetchOnlineRecipeInfo(id: String, completion: @escaping (OnlineRecipeInfoRecord?, Error?) -> Void) {
        db.collection(recipeInfoPath).document(id).getDocument { snapshot, err in
            guard let recipeInfoRecord = try? snapshot?.data(as: OnlineRecipeInfoRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(recipeInfoRecord, nil)
        }
    }

    func fetchAllUserInfos(completion: @escaping ([String: UserInfoRecord], Error?) -> Void) {
        var allUserInfoRecords = [String: UserInfoRecord]()
        db.collection(userInfoPath).getDocuments { snapshot, err in
            guard let userInfoRecords = (snapshot?.documents.compactMap { try? $0.data(as: UserInfoRecord.self) }), err == nil else {
                completion(allUserInfoRecords, err)
                return
            }

            for userInfo in userInfoRecords {
                guard let id = userInfo.id else {
                    continue
                }
                allUserInfoRecords[id] = userInfo
            }
            completion(allUserInfoRecords, nil)
        }
    }

    // used for users page
    func fetchUserInfos(ids: [String], completion: @escaping ([String: UserInfoRecord], Error?) -> Void) {
        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allUserInfoRecords = [String: UserInfoRecord]()

        let totalUserCount = ids.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + ids[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(userInfoPath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                guard let userInfoRecords = (snapshot?.documents.compactMap { try? $0.data(as: UserInfoRecord.self) }), err == nil else {
                    completion(allUserInfoRecords, err)
                    dispatchGroup.leave()
                    return
                }

                for userInfo in userInfoRecords {
                    guard let id = userInfo.id else {
                        continue
                    }
                    allUserInfoRecords[id] = userInfo
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(allUserInfoRecords, nil)
        }

    }

    func fetchUsers(ids: [String], completion: @escaping ([UserRecord], Error?) -> Void) {
        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allUserRecords: [UserRecord] = []

        let queryLimit = QueryLimiter(max: ids.count)
        while queryLimit.hasNext {
            let range = [] + ids[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(userPath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                guard let userRecords = (snapshot?.documents.compactMap { try? $0.data(as: UserRecord.self) }), err == nil else {
                    completion([], err)
                    dispatchGroup.leave()
                    return
                }

                allUserRecords.append(contentsOf: userRecords)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
           completion(allUserRecords, nil)
        }
    }

    // MARK: - FirebaseDatabase: Listeners

    func userListener(id: String, onChange: @escaping (UserRecord) -> Void) {
        db.collection(userPath).document(id)
            .addSnapshotListener { documentSnapshot, _ in
                guard let user = try? documentSnapshot?.data(as: UserRecord.self) else {
                    assertionFailure("No user")
                    return
                }
                onChange(user)
            }
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
