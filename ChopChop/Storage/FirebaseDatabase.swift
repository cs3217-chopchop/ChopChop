//
//  FirebaseDatabase.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import Firebase
//import FirebaseFirestoreSwift
import Combine
import CombineFirebase

struct FirebaseDatabase {
    private let recipePath: String = "recipes"
    private let userPath: String = "users"
    private let ratingPath: String = "ratings"
    private let db = Firestore.firestore()

    func addRecipe(recipe: OnlineRecipeRecord) throws -> String {
        do {
            return try db.collection(recipePath).addDocument(from: recipe).documentID
        } catch {
            throw FirebaseError.addRecipeError(message: "Unable to add recipe: \(error.localizedDescription)")
        }
    }
    // can remove the error part
    func removeRecipe(recipeId: String) throws {
        var hasError = false
        var errorMessage = ""
        db.collection(recipePath).document(recipeId).delete { error in
            if let error = error {
                hasError = true
                errorMessage = "Unable to remove recipe: \(error.localizedDescription)"
            }
        }
        if hasError {
            throw FirebaseError.removeRecipeError(message: errorMessage)
        }
    }
    func updateRecipeDetails(recipe: OnlineRecipeRecord) throws {
        guard let recipeId = recipe.id else {
            fatalError("Recipe does not have reference to online Id.")
        }

        return db.collection(recipePath).document(recipeId).setData([
            "name": recipe.name,
            "creator": recipe.creator,
            "servings": recipe.servings,
            "difficulty": recipe.difficulty?.rawValue,
            "cuisine": recipe.cuisine,
            "steps": recipe.steps,
            "ingredients": recipe.ingredients.map({ $0.toDict() })
        ], merge: true)
    }
//    func updateRecipeDetails(recipe: OnlineRecipeRecord) throws {
//        guard let recipeId = recipe.id else {
//            fatalError("Recipe does not have reference to online Id.")
//        }
//        _ = db.collection(recipePath).document(recipeId).setData(from: recipe)
//
//    }

    func fetchOnlineRecipeIdByUsers(userIds: [String]) -> AnyPublisher<[OnlineRecipeRecord], Error> {
        userIds.map({
            db.collection(recipePath).whereField("creator", isEqualTo: $0)
                .publisher()
        })
        .combineLatest
        .map({
            $0.reduce(into: [], {
                $0 += $1.documents
            })
        })
        .map({
            $0.compactMap({
                try? $0.data(as: OnlineRecipeRecord.self)
            })
        })
        .eraseToAnyPublisher()
    }

    func fetchAllRecipes() -> AnyPublisher<[OnlineRecipeRecord], Error> {
        db.collection(recipePath)
            .publisher()
            .map({
                $0.documents.compactMap({
                    try? $0.data(as: OnlineRecipeRecord.self)
                })
            })
            .eraseToAnyPublisher()
    }

    func fetchAllUsers() -> AnyPublisher<[User], Error> {
        db.collection(userPath)
            .publisher()
            .map({
                $0.documents.compactMap({
                    try? $0.data(as: User.self)
                })
            })
            .eraseToAnyPublisher()
    }

//    func fetchOnlineRecipeByUsers(userIds: [String]) throws -> AnyPublisher<[OnlineRecipeRecord], Error> {
//
////        db.collection(recipePath).whereField("userId", in: userIds)
////            .combine
////            .snapshotPublisher()
////            .map({
////                $0.documents.compactMap({ document in
////                    try? document.data(as: OnlineRecipeRecord.self)
////                })
////
////            })
////            .eraseToAnyPublisher()
//    }

    func fetchFriendsId(userId: String) -> AnyPublisher<[String], Error> {
        db.collection(userPath).document(userId)
            .publisher()
            .map({
                try? $0.data(as: User.self)
            })
            .map({
                $0?.followees ?? []
            })
            .eraseToAnyPublisher()
    }

    func fetchUsers(userId: [String]) -> AnyPublisher<[User], Error> {
        let docRefs = userId.map({
            db.collection(userPath).document($0)
        })
        return docRefs.map({
            $0.publisher().map({
                try? $0.data(as: User.self)
            })
        })
        .combineLatest
        .map({
            $0.compactMap({
                $0
            })
        })
        .eraseToAnyPublisher()
    }

    func fetchUserRating(userId: String) -> AnyPublisher<[UserRating], Error> {
        db.collection(userPath).document(userId)
            .getDocument()
            .compactMap({
                try? $0.data(as: User.self)?.ratings
            })
            .eraseToAnyPublisher()
    }

//    func fetchOnlineRecipeById(onlineRecipeId: String) throws -> OnlineRecipeRecord? {
//        var hasError = false
//        var errorMessage = ""
//        var fetchedRecipe: OnlineRecipeRecord?
//        do {
//            db.collection(recipePath).document(onlineRecipeId).addSnapshotListener { querySnapshot, error in
//                    if let error = error {
//                        hasError = true
//                        errorMessage = "Error fetching recipe: \(error.localizedDescription)"
//                    } else {
//                        fetchedRecipe = try? querySnapshot?.data(as: OnlineRecipeRecord.self)
//                    }
//            }
//        }
//        if hasError {
//            throw FirebaseError.fetchRecipeError(message: errorMessage)
//        } else {
//            return fetchedRecipe
//        }
//    }
    func addRating(rating: RatingRecord) throws {
        do {
            try _ = db.collection(ratingPath).addDocument(from: rating)
        } catch {
            throw FirebaseError.addRatingError(message: error.localizedDescription)
        }

    }

    func removeRating(ratingId: String) {
        // swiftlint:disable implicit_return
        return db.collection(ratingPath).document(ratingId).delete()
    }

    func removeRatingByUser(userId: String) {
        db.collection(ratingPath).whereField("userId", isEqualTo: userId)
            .getDocuments { querySnapshot, _ in
                guard let documents = querySnapshot?.documents else {
                    return
                }
                for documentSnapshot in documents {
                    return documentSnapshot.reference.delete()
                }

            }
    }

    func removeRatingByRecipe(recipeId: String) {
        db.collection(ratingPath).whereField("recipeId", isEqualTo: recipeId)
            .getDocuments { querySnapshot, _ in
                guard let documents = querySnapshot?.documents else {
                    return
                }
                for documentSnapshot in documents {
                    return documentSnapshot.reference.delete()
                }

            }
    }

//    func updateRating(ratingId: String, rating: RatingScore) {
//        // swiftlint:disable implicit_return
//        return db.collection(ratingPath).document(ratingId).updateData(["rating": rating.rawValue])
//    }
    func updateRecipeRating(userId: String, recipeId: String, newScore: RatingScore) {
        let docRef = db.collection(recipePath).document(recipeId)
        db.runTransction({ transaction -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(docRef)
            } catch {
                return nil
            }
            guard let recipeRatings = try? document.data(as: OnlineRecipeRecord.self)?.ratings else {
                return nil
            }

            var newRatingList = [RecipeRating]()

            for rating in recipeRatings {
                if rating.userId == userId {
                    newRatingList.append(RecipeRating(userId: userId, score: newScore))
                } else {
                    newRatingList.append(rating)
                }
            }

            transaction.updateData(["ratings": newRatingList.map({ $0.toDict() })], forDocument: docRef)
            return nil
        })
    }

    func updateUserRating(userId: String, recipeId: String, newScore: RatingScore) {
        let docRef = db.collection(userPath).document(userId)
        db.runTransction({ transaction -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(docRef)
            } catch {
                return nil
            }
            guard let userRatings = try? document.data(as: User.self)?.ratings else {
                return nil
            }

            var newRatingList = [UserRating]()

            for rating in userRatings {
                if rating.recipeId == recipeId {
                    newRatingList.append(UserRating(recipeOnlineId: recipeId, score: newScore))
                } else {
                    newRatingList.append(rating)
                }
            }

            transaction.updateData(["ratings": newRatingList.map({ $0.toDict() })], forDocument: docRef)
            return nil
        })
    }

    func fetchOnlineRecipeById(onlineRecipeId: String) -> AnyPublisher<OnlineRecipeRecord, Error> {

        db.collection(recipePath).document(onlineRecipeId)
            .publisher()
            .compactMap({ try? $0.data(as: OnlineRecipeRecord.self) })
            .eraseToAnyPublisher()
    }

    func fetchOnlineRecipeOnceById(onlineRecipeId: String) -> AnyPublisher<OnlineRecipeRecord, Error> {
        return db.collection(recipePath).document(onlineRecipeId)
            .getDocument(as: OnlineRecipeRecord.self)
            .compactMap {
                $0
            }
            .eraseToAnyPublisher()
    }

//    func fetchRecipeRatings(recipeId: String) -> AnyPublisher<[RatingRecord], Error> {
//        db.collection(ratingPath).whereField("recipeId", isEqualTo: recipeId)
//            .publisher()
//            .map({
//                $0.documents.compactMap({ document in
//                    try? document.data(as: RatingRecord.self)
//                })
//            })
//            .eraseToAnyPublisher()
//    }

//    func fetchRecipeById(recipeId: String) -> AnyPublisher<RecipeRecord?, Error> {
//        db.collection(recipePath).document(recipeId)
//            .combine
//            .snapshotPublisher()
//            .compactMap({
//                try? $0.data(as: RecipeRecord.self)
//            })
//            .mapError({
//                FirebaseError.fetchRecipeError(message: $0.localizedDescription)
//            })
//            .eraseToAnyPublisher()
//    }
//
//    func fetchRecipeByUser(creatorId: String) -> AnyPublisher<[RecipeRecord], Error> {
//        db.collection(recipePath).whereField("creatorId", isEqualTo: creatorId)
//            .combine
//            .snapshotPublisher()
//            .map({
//                $0.documents.compactMap({
//                    try? $0.data(as: RecipeRecord.self)
//                })
//            })
//            .eraseToAnyPublisher()
//    }

//    func fetchUserRatings(userId: String) -> AnyPublisher<[UserRating], Error> {
//        
//    }

//    func fetchOnlineRecipeByUser(userId: String) throws -> [OnlineRecipeRecord] {
//        var hasError = false
//        var errorMessage = ""
//        var fetchedRecipes = [OnlineRecipeRecord]()
//        do {
//            db.collection(recipePath).whereField("creator", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
//                    if let error = error {
//                        hasError = true
//                        errorMessage = "Error fetching recipes: \(error.localizedDescription)"
//                    } else {
//                        fetchedRecipes = querySnapshot?.documents.compactMap { document in
//                            try? document.data(as: OnlineRecipeRecord.self)
//                        } ?? []
//                    }
//            }
//        }
//        if hasError {
//            throw FirebaseError.fetchRecipeError(message: errorMessage)
//        } else {
//            return fetchedRecipes
//        }
//    }
    func addRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        let ratingData: [String: Any] = ["userId": rating.userId, "score": rating.score.rawValue]

        return db.collection(recipePath).document(onlineRecipeId)
            .updateData(["ratings": FieldValue.arrayUnion([ratingData])
            ])
    }
    func removeRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        let ratingData: [String: Any] = ["userId": rating.userId, "score": rating.score.rawValue]
        return db.collection(recipePath).document(onlineRecipeId)
            .updateData(["ratings": FieldValue.arrayRemove([ratingData])])
    }
//    func removeUserRatingForRecipe(onlineRecipeId: String) {
//        db.collection(userPath).whereField("ratings", in: <#T##[Any]#>)
//    }
    func addUserRecipeRating(userId: String, rating: UserRating) {
        let ratingData: [String: Any] = ["recipeId": rating.recipeId, "score": rating.score.rawValue]
        return db.collection(userPath).document(userId).updateData(["ratings": FieldValue.arrayUnion([ratingData])])
    }
    func removeUserRecipeRating(userId: String, rating: UserRating) {
//        let ratingData: [String: Any] = ["recipeId": rating.recipeId, "score": rating.score.rawValue]
        return db.collection(userPath).document(userId).updateData(["ratings": FieldValue.arrayRemove([rating.toDict()])])
    }
//    func addUser(username: String) -> String {
//        db.collection(userPath).addDocument(data: ["name": username]).documentID
//    }
    func addUser(user: User) throws -> String {
        try db.collection(userPath).addDocument(from: user).documentID
    }
    // can remove error part
    func removeUser(userId: String) throws {
        var hasError = false
        var errorMessage = ""
        db.collection(userPath).document(userId).delete { error in
            if let error = error {
                hasError = true
                errorMessage = "Unable to remove user: \(error.localizedDescription)"
            }
        }
        if hasError {
            throw FirebaseError.removeUserError(message: errorMessage)
        }
    }
    func fetchUserById(userId: String) throws -> AnyPublisher<User, Error> {
        db.collection(userPath).document(userId)
            .publisher()
            .compactMap({
                try? $0.data(as: User.self)
            })
            .eraseToAnyPublisher()
    }
    func addFollowee(userId: String, followeeId: String) {
        // swiftlint:disable implicit_return
        return db.collection(userPath).document(userId).updateData(["followees": FieldValue.arrayUnion([followeeId])])
    }

    func removeFollowee(userId: String, followeeId: String) {
        // swiftlint:disable implicit_return
        return db.collection(userPath).document(userId).updateData(["followees": FieldValue.arrayRemove([followeeId])])
    }
}

enum FirebaseError: Error {
    case addRecipeError(message: String), removeRecipeError(message: String),
         updateRecipeError(message: String), fetchRecipeError(message: String),
         addUserError(message: String), removeUserError(message: String), addRatingError(message: String)
}