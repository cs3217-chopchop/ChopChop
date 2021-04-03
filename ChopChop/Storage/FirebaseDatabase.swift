import Firebase
import Combine
import CombineFirebase

struct FirebaseDatabase {
    private let recipePath: String = "recipes"
    private let userPath: String = "users"
    private let db = Firestore.firestore()

    func addRecipe(recipe: OnlineRecipeRecord) throws -> String {
        do {
            return try db.collection(recipePath).addDocument(from: recipe).documentID
        } catch {
            throw FirebaseError.addRecipeError(message: "Unable to add recipe: \(error.localizedDescription)")
        }
    }
    func removeRecipe(recipeId: String) throws {
        // swiftlint:disable implicit_return
        return db.collection(recipePath).document(recipeId).delete()
    }
    func updateRecipeDetails(recipe: OnlineRecipeRecord) {
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
            "ingredients": recipe.ingredients.map({ $0.asDict })
        ], merge: true)
    }

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
                $0.documents
                    .compactMap({
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

    func fetchFolloweesId(userId: String) -> AnyPublisher<[String], Error> {
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

            transaction.updateData(["ratings": newRatingList.map({ $0.asDict })], forDocument: docRef)
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

            transaction.updateData(["ratings": newRatingList.map({ $0.asDict })], forDocument: docRef)
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

    func addRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        // swiftlint:disable implicit_return
        return db.collection(recipePath).document(onlineRecipeId)
            .updateData(["ratings": FieldValue.arrayUnion([rating.asDict])])
    }
    func removeRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        // swiftlint:disable implicit_return
        return db.collection(recipePath).document(onlineRecipeId)
            .updateData(["ratings": FieldValue.arrayRemove([rating.asDict])])
    }

    func addUserRecipeRating(userId: String, rating: UserRating) {
        // swiftlint:disable implicit_return
        return db.collection(userPath).document(userId)
            .updateData(["ratings": FieldValue.arrayUnion([rating.asDict])])
    }
    func removeUserRecipeRating(userId: String, rating: UserRating) {
        // swiftlint:disable implicit_return
        return db.collection(userPath).document(userId)
            .updateData(["ratings": FieldValue.arrayRemove([rating.asDict])])
    }

    func addUser(user: User) throws -> String {
        try db.collection(userPath).addDocument(from: user).documentID
    }
    func removeUser(userId: String) throws {
        return db.collection(userPath).document(userId).delete()
    }
    func fetchUserById(userId: String) -> AnyPublisher<User, Error> {
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
