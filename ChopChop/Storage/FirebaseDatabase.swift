// swiftlint:disable file_length type_body_length

import Firebase
import Combine

struct FirebaseDatabase {
    private let recipePath: String = "recipes"
    private let recipeInfoPath: String = "recipeInfos"
    private let userPath: String = "users"
    private let userInfoPath: String = "userInfos"
    private let db = Firestore.firestore()

    // MARK: - FirebaseDatabase: Create/Update

    /**
     Creates OnlineRecipeRecord and OnlineRecipeInfoRecord in Firebase
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func addOnlineRecipe(recipe: OnlineRecipeRecord, completion: @escaping (Error?) -> Void) throws -> String {
        let recipeDocRef = db.collection(recipePath).document()
        let batch = db.batch()
        try batch.setData(from: recipe, forDocument: recipeDocRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(recipeDocRef.documentID)
        let recipeInfo = OnlineRecipeInfoRecord(id: recipeDocRef.documentID, creatorId: recipe.creatorId)
        try batch.setData(from: recipeInfo, forDocument: recipeInfoRef)

        batch.commit { err in
            completion(err)
        }
        return recipeDocRef.documentID
    }

    /**
     Updates OnlineRecipeRecord and timestamps in OnlineRecipeInfoRecord in Firebase
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func updateOnlineRecipe(recipe: OnlineRecipeRecord, isImageUploadedAlready: Bool,
                            completion: @escaping (Error?) -> Void) {
        guard let recipeId = recipe.id else {
            fatalError("Recipe does not have reference to online Id.")
        }

        let batch = db.batch()
        let recipeDocRef = db.collection(recipePath).document(recipeId)
        batch.setData([
            "name": recipe.name,
            "creatorId": recipe.creatorId,
            "servings": recipe.servings,
            "difficulty": recipe.difficulty?.rawValue as Any,
            "cuisine": recipe.cuisine as Any,
            "steps": recipe.steps.map({ $0.asDict }),
            "stepEdges": recipe.stepEdges.map({ $0.asDict }),
            "ingredients": recipe.ingredients.map({ $0.asDict })
        ], forDocument: recipeDocRef, merge: true)

        let recipeInfoDocRef = db.collection(recipeInfoPath).document(recipeId)
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

        batch.commit { err in
            completion(err)
        }
    }

    /**
     Add a rating of an OnlineRecipe and updates timestamp in OnlineRecipeInfoRecord.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func addOnlineRecipeRating(onlineRecipeId: String, rating: RecipeRating, completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        let recipeRef = db.collection(recipePath).document(onlineRecipeId)
        batch.updateData(["ratings": FieldValue.arrayUnion([rating.asDict])], forDocument: recipeRef)

        let recipeInfoRef = db.collection(recipeInfoPath).document(onlineRecipeId)
        batch.updateData(["updatedAt": FieldValue.serverTimestamp()], forDocument: recipeInfoRef)

        batch.commit { err in
            completion(err)
        }
    }

    /**
     Updates a rating of an OnlineRecipe and updates timestamp in OnlineRecipeInfoRecord.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func updateOnlineRecipeRating(
        recipeId: String,
        oldRating: RecipeRating,
        newRating: RecipeRating,
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

    /**
     Add a UserRating to the User and updates timestamp in the UserRecord.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
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

    /**
     Updates a UserRating of the User and updates timestamp in the UserRecord.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func updateUserRating(userId: String, oldRating: UserRating, newRating: UserRating,
                          completion: @escaping (Error?) -> Void) {
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

    /**
     Adds a UserRecord and UserInfoRecord to Firebase.
     Signals completion via a completion handler and returns:
     - the `userId` of the new user
     - error in completion handler if any
     */
    func addUser(user: UserRecord, completion: @escaping (String?, Error?) -> Void) throws {
        let userRef = db.collection(userPath).document()
        let batch = db.batch()
        try batch.setData(from: user, forDocument: userRef)

        let userInfo = UserInfoRecord(id: userRef.documentID)
        let userInfoRef = db.collection(userInfoPath).document(userRef.documentID)
        try batch.setData(from: userInfo, forDocument: userInfoRef)

        batch.commit { err in
            completion(userRef.documentID, err)
        }
    }

    /**
     Adds a followee of that followeeId to the user of that userId
     Signals completion via a completion handler and returns an error in completion handler if any.
     */
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

    /**
     Delete an OnlineRecipeRecord and OnlineRecipeInfoRecord, effectively unpublishing the recipe.
     Signals completion via a completion handler and returns an error in completion handler if any.
     */
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

    /**
     Removes a rating of an OnlineRecipeRecord and update timestamp in OnlineRecipeInfoRecord.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
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

    /**
     Removes a UserRating of an User and update timestamp in UserInfoRecord.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
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

    /**
     Removes a followee of that followeeId from user of that userId and and update timestamp in UserInfoRecord.
     Signals completion via a completion handler and returns an error in completion handler if any.
     */
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

    /**
     Fetches UserInfo of that id
     Signals completion via a completion handler and returns the UserInfoRecord and error in completion handler if any.
     */
    func fetchUserInfo(id: String, completion: @escaping (UserInfoRecord?, Error?) -> Void) {
        db.collection(userInfoPath).document(id).getDocument { document, err in
            guard let userInfo = try? document?.data(as: UserInfoRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(userInfo, nil)
        }
    }

    /**
     Fetches user of that id
     Signals completion via a completion handler and returns the UserRecord and error in completion handler if any.
     */
    func fetchUser(id: String, completion: @escaping (UserRecord?, Error?) -> Void) {
        db.collection(userPath).document(id).getDocument { document, err in
            guard let user = try? document?.data(as: UserRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(user, nil)
        }
    }

    /**
     Fetches OnlineRecipeInfos whose creatorId is included in userIds
     Signals completion via a completion handler and returns:
     - the OnlineRecipeInfoRecords
     - error in completion handler if any
     */
    func fetchOnlineRecipeInfos(userIds: [String],
                                completion: @escaping ([String: OnlineRecipeInfoRecord], Error?) -> Void) {

        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allOnlineRecipeInfoRecords = [String: OnlineRecipeInfoRecord]()

        let totalUserCount = userIds.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + userIds[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(recipeInfoPath).whereField("creatorId", in: range).getDocuments { snapshot, err in
                guard let recipeInfoRecords = (snapshot?.documents
                                                .compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }),
                      err == nil else {
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

    /**
     Fetches all OnlineRecipeInfos
     Signals completion via a completion handler and returns:
     - the OnlineRecipeInfoRecords
     - error in completion handler if any.
     */
    func fetchAllOnlineRecipeInfos(completion: @escaping ([String: OnlineRecipeInfoRecord], Error?) -> Void) {
        db.collection(recipeInfoPath).getDocuments { snapshot, err in
            var allOnlineRecipeInfoRecords = [String: OnlineRecipeInfoRecord]()

            guard let recipeInfoRecords = (snapshot?.documents
                                            .compactMap { try? $0.data(as: OnlineRecipeInfoRecord.self) }),
                  err == nil else {
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

    /**
     Fetches OnlineRecipeRecords whose ids are included in ids
     Signals completion via a completion handler and returns:
     - the OnlineRecipeRecords
     - error in completion handler if any.
     */
    func fetchOnlineRecipes(ids: [String], completion: @escaping ([OnlineRecipeRecord], Error?) -> Void) {

        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allOnlineRecipeRecords: [OnlineRecipeRecord] = []

        let queryLimit = QueryLimiter(max: ids.count)
        while queryLimit.hasNext {
            let range = [] + ids[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(recipePath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                guard let recipeRecords = (snapshot?.documents
                                            .compactMap { try? $0.data(as: OnlineRecipeRecord.self) }),
                      err == nil else {
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

    /**
     Fetches OnlineRecipe of that id
     Signals completion via a completion handler and returns:
     - the OnlineRecipeRecord
     - error in completion handler if any
     */
    func fetchOnlineRecipe(id: String, completion: @escaping (OnlineRecipeRecord?, Error?) -> Void) {
        db.collection(recipePath).document(id).getDocument { snapshot, err in
            guard let recipeRecord = try? snapshot?.data(as: OnlineRecipeRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(recipeRecord, nil)
        }
    }

    /**
     Fetches OnlineRecipeInfo of that id
     Signals completion via a completion handler and returns:
     - the OnlineRecipeInfoRecord
     - error in completion handler if any
     */
    func fetchOnlineRecipeInfo(id: String, completion: @escaping (OnlineRecipeInfoRecord?, Error?) -> Void) {
        db.collection(recipeInfoPath).document(id).getDocument { snapshot, err in
            guard let recipeInfoRecord = try? snapshot?.data(as: OnlineRecipeInfoRecord.self), err == nil else {
                completion(nil, err)
                return
            }
            completion(recipeInfoRecord, nil)
        }
    }

    /**
     Fetches all UserInfos
     Signals completion via a completion handler and returns the UserInfoRecords and error in completion handler if any.
     */
    func fetchAllUserInfos(completion: @escaping ([String: UserInfoRecord], Error?) -> Void) {
        var allUserInfoRecords = [String: UserInfoRecord]()
        db.collection(userInfoPath).getDocuments { snapshot, err in
            guard let userInfoRecords = (snapshot?.documents
                                            .compactMap { try? $0.data(as: UserInfoRecord.self) }),
                  err == nil else {
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

    /**
     Fetches UserInfos whose ids are in ids
     Signals completion via a completion handler and returns the UserInfoRecords and error in completion handler if any.
     */
    func fetchUserInfos(ids: [String], completion: @escaping ([String: UserInfoRecord], Error?) -> Void) {
        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allUserInfoRecords = [String: UserInfoRecord]()

        let totalUserCount = ids.count
        let queryLimit = QueryLimiter(max: totalUserCount)
        while queryLimit.hasNext {
            let range = [] + ids[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(userInfoPath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                guard let userInfoRecords = (snapshot?.documents
                                                .compactMap { try? $0.data(as: UserInfoRecord.self) }),
                      err == nil else {
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

    /**
     Fetches all Users whos ids are in ids
     Signals completion via a completion handler and returns the UserRecords and error in completion handler if any.
     */
    func fetchUsers(ids: [String], completion: @escaping ([UserRecord], Error?) -> Void) {
        let dispatchGroup = DispatchGroup() // make sure its all collected before calling completion handler
        var allUserRecords: [UserRecord] = []

        let queryLimit = QueryLimiter(max: ids.count)
        while queryLimit.hasNext {
            let range = [] + ids[queryLimit.current..<queryLimit.next()]
            dispatchGroup.enter()
            db.collection(userPath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
                guard let userRecords = (snapshot?.documents
                                            .compactMap { try? $0.data(as: UserRecord.self) }),
                      err == nil else {
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

    /**
     Listens to the details of a single user.
     */
    func userListener(id: String, onChange: @escaping (UserRecord) -> Void) {
        db.collection(userPath).document(id)
            .addSnapshotListener { documentSnapshot, _ in
                guard let user = try? documentSnapshot?.data(as: UserRecord.self) else {
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
