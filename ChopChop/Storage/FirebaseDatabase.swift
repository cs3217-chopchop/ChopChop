//
//  FirebaseDatabase.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

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
    func updateRecipe(recipe: OnlineRecipeRecord) throws {
        guard let recipeId = recipe.id else {
            fatalError("Recipe does not have reference to online Id.")
        }
        do {
            try db.collection(recipePath).document(recipeId).setData([
                "name": recipe.name,
                "creator": recipe.creator,
                "servings": recipe.servings,
                "difficulty": recipe.difficulty?.rawValue ?? 0,
                "cuisine": recipe.cuisine,
                "steps": recipe.steps,
                "ingredients": recipe.ingredients
            ])
        } catch {
            throw FirebaseError.updateRecipeError(message: "Unable to update recipe: \(error.localizedDescription)")
        }
    }

    func fetchOnlineRecipeById(onlineRecipeId: String) throws -> OnlineRecipeRecord? {
        var hasError = false
        var errorMessage = ""
        var fetchedRecipe: OnlineRecipeRecord?
        do {
            db.collection(recipePath).document(onlineRecipeId).addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        hasError = true
                        errorMessage = "Error fetching recipe: \(error.localizedDescription)"
                    } else {
                        fetchedRecipe = try? querySnapshot?.data(as: OnlineRecipeRecord.self)
                    }
            }
        }
        if hasError {
            throw FirebaseError.fetchRecipeError(message: errorMessage)
        } else {
            return fetchedRecipe
        }
    }
    func fetchOnlineRecipeByUser(userId: String) throws -> [OnlineRecipeRecord] {
        var hasError = false
        var errorMessage = ""
        var fetchedRecipes = [OnlineRecipeRecord]()
        do {
            db.collection(recipePath).whereField("creator", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        hasError = true
                        errorMessage = "Error fetching recipes: \(error.localizedDescription)"
                    } else {
                        fetchedRecipes = querySnapshot?.documents.compactMap { document in
                            try? document.data(as: OnlineRecipeRecord.self)
                        } ?? []
                    }
            }
        }
        if hasError {
            throw FirebaseError.fetchRecipeError(message: errorMessage)
        } else {
            return fetchedRecipes
        }
    }
    func addOnlineRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        let ratingData: [String: Any] = ["userId": rating.userId, "score": rating.score.rawValue]

        db.collection(recipePath).document(onlineRecipeId)
            .updateData(["ratings": FieldValue.arrayUnion([ratingData])
            ])
    }
    func removeRecipeRating(onlineRecipeId: String, rating: RecipeRating) {
        let ratingData: [String: Any] = ["userId": rating.userId, "score": rating.score.rawValue]
        db.collection(recipePath).document(onlineRecipeId)
            .updateData(["ratings": FieldValue.arrayRemove([ratingData])])
    }
    func addUserRecipeRating(userId: String, rating: UserRating) {
        let ratingData: [String: Any] = ["recipeId": rating.recipeOnlineId, "score": rating.score.rawValue]
        db.collection(userPath).document(userId).updateData(["ratings": FieldValue.arrayUnion([ratingData])])
    }
    func removeUserRecipeRating(userId: String, rating: UserRating) {
        let ratingData: [String: Any] = ["recipeId": rating.recipeOnlineId, "score": rating.score.rawValue]
        db.collection(userPath).document(userId).updateData(["ratings": FieldValue.arrayRemove([ratingData])])
    }
    func createNewUser(username: String) -> String {
        db.collection(userPath).addDocument(data: ["name": username]).documentID
    }
    func addFollowee(userId: String, followeeId: String) {
        db.collection(userPath).document(userId).updateData(["followees": FieldValue.arrayUnion([followeeId])])
    }

    func removeFollowee(userId: String, followeeId: String) {
        db.collection(userPath).document(userId).updateData(["followees": FieldValue.arrayRemove([followeeId])])
    }
}

enum FirebaseError: Error {
    case addRecipeError(message: String), removeRecipeError(message: String),
         updateRecipeError(message: String), fetchRecipeError(message: String),
         addUserError(message: String)
}
