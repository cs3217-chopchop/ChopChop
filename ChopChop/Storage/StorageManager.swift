import Foundation
import UIKit
import Combine

struct StorageManager {
    let appDatabase: AppDatabase
    let firebase = FirebaseDatabase()

    init(appDatabase: AppDatabase = .shared) {
        self.appDatabase = appDatabase
    }

    // MARK: - Storage Manager: Create/Update

    func saveRecipe(_ recipe: inout Recipe) throws {
        var recipeRecord = RecipeRecord(id: recipe.id, recipeCategoryId: recipe.recipeCategoryId, name: recipe.name,
                                        servings: recipe.servings, difficulty: recipe.difficulty)
        var ingredientRecords = recipe.ingredients.map { ingredient in
            RecipeIngredientRecord(recipeId: recipe.id, name: ingredient.name, quantity: ingredient.quantity.record)
        }
        var stepRecords = recipe.steps.enumerated().map { index, step in
            RecipeStepRecord(recipeId: recipe.id, index: index + 1, content: step.content)
        }

        try appDatabase.saveRecipe(&recipeRecord, ingredients: &ingredientRecords, steps: &stepRecords)

        recipe.id = recipeRecord.id
    }

    func saveRecipeCategory(_ recipeCategory: inout RecipeCategory) throws {
        var recipeCategoryRecord = RecipeCategoryRecord(id: recipeCategory.id, name: recipeCategory.name)

        try appDatabase.saveRecipeCategory(&recipeCategoryRecord)

        recipeCategory.id = recipeCategoryRecord.id
    }

    func saveIngredient(_ ingredient: inout Ingredient) throws {
        var ingredientRecord = IngredientRecord(id: ingredient.id,
                                                ingredientCategoryId: ingredient.ingredientCategoryId,
                                                name: ingredient.name,
                                                quantityType: ingredient.quantityType)
        var batchRecords = ingredient.batches.map { batch in
            IngredientBatchRecord(ingredientId: ingredient.id,
                                  expiryDate: batch.expiryDate,
                                  quantity: batch.quantity.record)
        }

        try appDatabase.saveIngredient(&ingredientRecord, batches: &batchRecords)

        ingredient.id = ingredientRecord.id
    }

    func saveIngredientCategory(_ ingredientCategory: inout IngredientCategory) throws {
        var ingredientCategoryRecord = IngredientCategoryRecord(id: ingredientCategory.id,
                                                                name: ingredientCategory.name)

        try appDatabase.saveIngredientCategory(&ingredientCategoryRecord)

        ingredientCategory.id = ingredientCategoryRecord.id
    }

    // MARK: - StorageManager: Delete

    func deleteRecipes(ids: [Int64]) throws {
        try appDatabase.deleteRecipes(ids: ids)
    }

    func deleteAllRecipes() throws {
        try appDatabase.deleteAllRecipes()
    }

    func deleteRecipeCategories(ids: [Int64]) throws {
        try appDatabase.deleteRecipeCategories(ids: ids)
    }

    func deleteAllRecipeCategories() throws {
        try appDatabase.deleteAllRecipeCategories()
    }

    func deleteIngredients(ids: [Int64]) throws {
        try appDatabase.deleteIngredients(ids: ids)
    }

    func deleteAllIngredients() throws {
        try appDatabase.deleteAllIngredients()
    }

    func deleteIngredientCategories(ids: [Int64]) throws {
        try appDatabase.deleteIngredientCategories(ids: ids)
    }

    func deleteAllIngredientCategories() throws {
        try appDatabase.deleteAllIngredientCategories()
    }

    // MARK: - Storage Manager: Read

    func fetchRecipe(id: Int64) throws -> Recipe? {
        try appDatabase.fetchRecipe(id: id)
    }

    func fetchIngredient(id: Int64) throws -> Ingredient? {
        try appDatabase.fetchIngredient(id: id)
    }

    func fetchRecipeCategory(id: Int64) throws -> RecipeCategory? {
        try appDatabase.fetchRecipeCategory(id: id)
    }

    // MARK: - Database Access: Publishers

    func recipePublisher(id: Int64) -> AnyPublisher<Recipe?, Error> {
        appDatabase.recipePublisher(id: id)
    }

    func recipesPublisher(query: String,
                          categoryIds: [Int64?],
                          ingredients: [String]) -> AnyPublisher<[RecipeInfo], Error> {
        appDatabase.recipesPublisher(query: query, categoryIds: categoryIds, ingredients: ingredients)
            .map { $0.map { RecipeInfo(id: $0.id, name: $0.name, servings: $0.servings, difficulty: $0.difficulty) } }
            .eraseToAnyPublisher()
    }

    func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Error> {
        appDatabase.recipeCategoriesPublisher()
            .map { $0.compactMap { try? RecipeCategory(name: $0.name, id: $0.id) } }
            .eraseToAnyPublisher()
    }

    func recipeIngredientsPublisher(categoryIds: [Int64?]) -> AnyPublisher<[String], Error> {
        appDatabase.recipeIngredientsPublisher(categoryIds: categoryIds)
            .map { Array(Set($0.map { $0.name })).sorted() }
            .eraseToAnyPublisher()
    }

    func ingredientPublisher(id: Int64) -> AnyPublisher<Ingredient?, Error> {
        appDatabase.ingredientPublisher(id: id)
    }

    func ingredientsPublisher() -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsPublisher()
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name, quantity: String($0.totalQuantityDescription)) } }
            .eraseToAnyPublisher()
    }

    func ingredientsPublisher(query: String, categoryIds: [Int64?]) -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsPublisher(query: query, categoryIds: categoryIds)
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name, quantity: String($0.totalQuantityDescription)) } }
            .eraseToAnyPublisher()
    }

    func ingredientsPublisher(query: String,
                              categoryIds: [Int64?],
                              expiresAfter: Date,
                              expiresBefore: Date) -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsPublisher(expiresAfter: expiresAfter,
                                         expiresBefore: expiresBefore,
                                         query: query,
                                         categoryIds: categoryIds)
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name, quantity: String($0.totalQuantityDescription)) } }
            .eraseToAnyPublisher()
    }

    func ingredientCategoriesPublisher() -> AnyPublisher<[IngredientCategory], Error> {
        appDatabase.ingredientCategoriesPublisher()
            .map { $0.compactMap { try? IngredientCategory(name: $0.name, id: $0.id) } }
            .eraseToAnyPublisher()
    }
}

// MARK: - Image Persistence
extension StorageManager {
    static let ingredientFolderName = "Ingredient"
    static let recipeFolderName = "Recipe"

    func deleteRecipeImage(name: String) {
        ImageStore.delete(imageNamed: name, inFolderNamed: StorageManager.recipeFolderName)
    }

    func renameRecipeImage(from oldName: String, to newName: String) throws {
        guard oldName != newName else {
            return
        }

        guard let image = fetchRecipeImage(name: oldName) else {
            return
        }

        try saveRecipeImage(image, name: newName)
        deleteRecipeImage(name: oldName)
    }

    func fetchRecipeImage(name: String) -> UIImage? {
        ImageStore.fetch(imageNamed: name, inFolderNamed: StorageManager.recipeFolderName)
    }

    func saveRecipeImage(_ image: UIImage, name: String) throws {
        try ImageStore.save(image: image, name: name, inFolderNamed: StorageManager.recipeFolderName)
    }

    func deleteIngredientImage(name: String) {
        ImageStore.delete(imageNamed: name, inFolderNamed: StorageManager.ingredientFolderName)
    }

    func renameIngredientImage(from oldName: String, to newName: String) throws {
        guard oldName != newName else {
            return
        }

        guard let image = fetchIngredientImage(name: oldName) else {
            return
        }

        try saveIngredientImage(image, name: newName)
        deleteIngredientImage(name: oldName)
    }

    func fetchIngredientImage(name: String) -> UIImage? {
        ImageStore.fetch(imageNamed: name, inFolderNamed: StorageManager.ingredientFolderName)
    }

    func saveIngredientImage(_ image: UIImage, name: String) throws {
        do {
            try ImageStore.save(image: image, name: name, inFolderNamed: StorageManager.ingredientFolderName)
        } catch {
            throw StorageError.saveImageFailure
        }
    }
}

// MARK: - Firebase operations
extension StorageManager {

    func publishRecipe(recipe: inout Recipe, userId: String) throws {
        var cuisine = ""
        if let categoryId = recipe.recipeCategoryId {
            cuisine = (try? (fetchRecipeCategory(id: categoryId)?.name) ?? "") ?? ""
        }
        let steps = recipe.steps.map({ $0.content })
        let ingredients = recipe.ingredients.map({
            OnlineIngredientRecord(name: $0.name, quantity: $0.quantity.record)
        })
        let recipeRecord = OnlineRecipeRecord(
            name: recipe.name,
            creator: userId,
            servings: recipe.servings,
            cuisine: cuisine,
            difficulty: recipe.difficulty,
            ingredients: ingredients,
            steps: steps
        )
        let onlineId = try firebase.addRecipe(recipe: recipeRecord)
        recipe.onlineId = onlineId
        try self.saveRecipe(&recipe)
    }

    // this should only be called once when the app first launched
    func createUser(name: String) throws -> String {
        let user = User(name: name)
        return try firebase.addUser(user: user)
    }

    func updateOnlineRecipe(recipe: Recipe, userId: String) throws {
        var cuisine = ""
        if let categoryId = recipe.recipeCategoryId {
            cuisine = (try? (fetchRecipeCategory(id: categoryId)?.name) ?? "") ?? ""
        }
        let steps = recipe.steps.map({ $0.content })
        let ingredients = recipe.ingredients.map({
            OnlineIngredientRecord(name: $0.name, quantity: $0.quantity.record)
        })
        let recipeRecord = OnlineRecipeRecord(
            id: recipe.onlineId,
            name: recipe.name,
            creator: userId,
            servings: recipe.servings,
            cuisine: cuisine,
            difficulty: recipe.difficulty,
            ingredients: ingredients,
            steps: steps
        )
        try firebase.updateRecipeDetails(recipe: recipeRecord)
    }

    func removeRecipe(recipe: OnlineRecipe) throws {
//        guard let id = recipe.id else {
//            fatalError("Online recipe has no id.")
//        }

        try firebase.removeRecipe(recipeId: recipe.id)
//        for rating in recipe.ratings {
//            firebase.removeRating(ratingId: rating.ratingId)
//        }
        for rating in recipe.ratings {
            firebase.removeUserRecipeRating(userId: rating.userId, rating: UserRating(recipeOnlineId: recipe.id, score: rating.score))
        }
    }

    func addFollowee(userId: String, followeeId: String) {
        firebase.addFollowee(userId: userId, followeeId: followeeId)
    }

    func removeFollowee(userId: String, followeeId: String) {
        firebase.removeFollowee(userId: userId, followeeId: followeeId)
    }

    func rateRecipe(recipeId: String, userId: String, rating: RatingScore) throws {
        firebase.addUserRecipeRating(userId: userId, rating: UserRating(recipeOnlineId: recipeId, score: rating))
        firebase.addRecipeRating(onlineRecipeId: recipeId, rating: RecipeRating(userId: userId, score: rating))
//        let ratingRecord = RatingRecord(userId: recipeId, recipeId: userId, rating: rating)
//        try firebase.addRating(rating: ratingRecord)
    }

//    func unrateRecipe(ratingId: String) {
//        firebase.removeRating(ratingId: ratingId)
//    }
    func unrateRecipe(recipeId: String, rating: RecipeRating) {
        firebase.removeRecipeRating(onlineRecipeId: recipeId, rating: rating)
        firebase.removeUserRecipeRating(userId: rating.userId, rating: UserRating(recipeOnlineId: recipeId, score: rating.score))
    }

//    func rerateRecipe(ratingId: String, newRating: RatingScore) {
//        firebase.updateRating(ratingId: ratingId, rating: newRating)
//    }
    func rerateRecipe(recipeId: String, newRating: RecipeRating) {
        firebase.updateRecipeRating(userId: newRating.userId, recipeId: recipeId, newScore: newRating.score)
        firebase.updateUserRating(userId: newRating.userId, recipeId: recipeId, newScore: newRating.score)
    }

    func fetchAllFriends(userId: String) -> AnyPublisher<[User], Error> {
        firebase.fetchFriendsId(userId: userId)
            .flatMap({ followees in
                firebase.fetchUsers(userId: followees)
            })
            .eraseToAnyPublisher()
    }

    //testing
//    func fetchAllUsers(user: [String]) -> AnyPublisher<[User], Error> {
//        firebase.fetchUsers(userId: user)
//    }
    func fetchAllPublishedRecipes(userId: String) -> AnyPublisher<[OnlineRecipe], Error> {
        firebase.fetchOnlineRecipeIdByUsers(userIds: [userId])
            .map({
                $0.compactMap({
                    try? $0.toOnlineRecipe()
                })
            })
            .eraseToAnyPublisher()
    }

    func fetchAllRecipes() -> AnyPublisher<[OnlineRecipe], Error> {
        firebase.fetchAllRecipes()
            .map({
                $0.compactMap({
                    try? $0.toOnlineRecipe()
                })
            })
            .eraseToAnyPublisher()
    }

    func fetchAllUsers() -> AnyPublisher<[User], Error> {
        firebase.fetchAllUsers()
    }

    func fetchAllFolloweeRecipes(followees: [String]) -> AnyPublisher<[OnlineRecipe], Error> {
        firebase.fetchOnlineRecipeIdByUsers(userIds: followees)
            .map({
                $0.compactMap({
                    try? $0.toOnlineRecipe()
                })
            })
            .eraseToAnyPublisher()
    }
    func fetchAllUserRatings(userId: String) -> AnyPublisher<[UserRating], Error> {
        firebase.fetchUserRating(userId: userId)
    }
    // currently recipe cuisine is lost
//    func downloadRecipe(recipeId: String) throws {
//        let fetchedRecipe = firebase.fetchOnlineRecipeOnceById(onlineRecipeId: recipeId)
//        var recipe = try Recipe(
//            name: fetchedRecipe.name,
//            servings: fetchedRecipe.servings,
//            difficulty: fetchedRecipe.difficulty,
//            steps: fetchedRecipe.steps.map({ try RecipeStep(content: $0) }),
//            ingredients: fetchedRecipe.ingredients.map({ try $0.toRecipeIngredient() })
//        )
//        try self.saveRecipe(&recipe)
//    }
}

enum StorageError: Error {
    case saveImageFailure
}
