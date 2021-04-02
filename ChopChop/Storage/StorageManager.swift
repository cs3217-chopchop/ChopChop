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

    func fetchRecipeByOnlineId(onlineId: String) throws -> Recipe? {
        try appDatabase.fetchRecipeByOnlineId(onlineId: onlineId)
    }

    func fetchIngredient(id: Int64) throws -> Ingredient? {
        try appDatabase.fetchIngredient(id: id)
    }

    func fetchRecipeCategory(id: Int64) throws -> RecipeCategory? {
        try appDatabase.fetchRecipeCategory(id: id)
    }

    func fetchRecipeCategoryByName(name: String) throws -> RecipeCategory? {
        try appDatabase.fetchRecipeCategoryByName(name: name)
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

    // publish your local recipe online
    func publishRecipe(recipe: inout Recipe, userId: String) throws {
        var cuisine: String?
        if let categoryId = recipe.recipeCategoryId {
            cuisine = try? fetchRecipeCategory(id: categoryId)?.name
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
    func createUser(user: User) throws -> String {
        try firebase.addUser(user: user)
    }

    // update details of published recipe (note that ratings cant be updated here)
    func updateOnlineRecipe(recipe: Recipe, userId: String) throws {
        var cuisine: String?
        if let categoryId = recipe.recipeCategoryId {
            cuisine = try? fetchRecipeCategory(id: categoryId)?.name
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

    // unpublish a recipe through the online interface
    func removeRecipeFromOnline(recipe: OnlineRecipe) throws {
        try firebase.removeRecipe(recipeId: recipe.id)
        for rating in recipe.ratings {
            firebase.removeUserRecipeRating(
                userId: rating.userId,
                rating: UserRating(recipeOnlineId: recipe.id, score: rating.score)
            )
        }
        let fetchedRecipe = try self.fetchRecipeByOnlineId(onlineId: recipe.id)
        guard var localRecipe = fetchedRecipe else {
            return
        }
        localRecipe.onlineId = nil
        try self.saveRecipe(&localRecipe)
    }

    // fetch the details of a single recipe
    func onlineRecipeByIdPublisher(recipeId: String) -> AnyPublisher<OnlineRecipe, Error> {
        firebase.fetchOnlineRecipeById(onlineRecipeId: recipeId)
            .compactMap({
                try? OnlineRecipe(from: $0)
            })
            .eraseToAnyPublisher()
    }

    // fetch the details of a single user
    func userByIdPublisher(userId: String) throws -> AnyPublisher<User, Error> {
        try firebase.fetchUserById(userId: userId)
    }

    // follow someone
    func addFollowee(userId: String, followeeId: String) {
        firebase.addFollowee(userId: userId, followeeId: followeeId)
    }

    // unfollow someone
    func removeFollowee(userId: String, followeeId: String) {
        firebase.removeFollowee(userId: userId, followeeId: followeeId)
    }

    // rate a recipe
    func rateRecipe(recipeId: String, userId: String, rating: RatingScore) throws {
        firebase.addUserRecipeRating(userId: userId, rating: UserRating(recipeOnlineId: recipeId, score: rating))
        firebase.addRecipeRating(onlineRecipeId: recipeId, rating: RecipeRating(userId: userId, score: rating))
    }

    // remove rating of a recipe you rated
    func unrateRecipe(recipeId: String, rating: RecipeRating) {
        firebase.removeRecipeRating(onlineRecipeId: recipeId, rating: rating)
        firebase.removeUserRecipeRating(
            userId: rating.userId,
            rating: UserRating(recipeOnlineId: recipeId, score: rating.score)
        )
    }

    // change the rating of a recipe you have rated before
    func rerateRecipe(recipeId: String, newRating: RecipeRating) {
        firebase.updateRecipeRating(userId: newRating.userId, recipeId: recipeId, newScore: newRating.score)
        firebase.updateUserRating(userId: newRating.userId, recipeId: recipeId, newScore: newRating.score)
    }

    // fetch user details of all your followees
    func allFolloweesPublisher(userId: String) -> AnyPublisher<[User], Error> {
        firebase.fetchFolloweesId(userId: userId)
            .flatMap({ followees in
                firebase.fetchUsers(userId: followees)
            })
            .eraseToAnyPublisher()
    }

    // fetch all recipes published by everyone
    func allRecipesPublisher() -> AnyPublisher<[OnlineRecipe], Error> {
        firebase.fetchAllRecipes()
            .map({
                $0.compactMap({
                    try? OnlineRecipe(from: $0)
                })
                .sorted(by: { $0.created > $1.created })
            })
            .eraseToAnyPublisher()
    }

    // Fetch details of all users in the system
    func allUsersPublisher() -> AnyPublisher<[User], Error> {
        firebase.fetchAllUsers()
    }

    // Can be used to fetch all your own recipes or recipes of several selected users
    func allRecipesByUsersPublisher(userIds: [String]) -> AnyPublisher<[OnlineRecipe], Error> {
        firebase.fetchOnlineRecipeIdByUsers(userIds: userIds)
            .map({
                $0.compactMap({
                    try? OnlineRecipe(from: $0)
                })
                .sorted(by: { $0.created > $1.created })
            })
            .eraseToAnyPublisher()
    }

    func allFolloweesRecipePublisher(userId: String) -> AnyPublisher<[OnlineRecipe], Error> {
        firebase.fetchFolloweesId(userId: userId)
            .flatMap({
                self.allRecipesByUsersPublisher(userIds: $0)
            })
            .eraseToAnyPublisher()
    }

    // Fetch all the recipe ratings that a particular user has given
    func allUserRatingsPublisher(userId: String) -> AnyPublisher<[UserRating], Error> {
        firebase.fetchUserRating(userId: userId)
    }

    // download an online recipe to local
    func downloadRecipe(newName: String, recipe: OnlineRecipe) throws {
        var cuisineId: Int64?
        if let cuisine = recipe.cuisine {
            cuisineId = try self.fetchRecipeCategoryByName(name: cuisine)?.id
        }
        var localRecipe = try Recipe(
            name: newName,
            onlineId: recipe.id,
            servings: recipe.servings,
            recipeCategoryId: cuisineId,
            difficulty: recipe.difficulty,
            steps: try recipe.steps.map({ try RecipeStep(content: $0) }),
            ingredients: recipe.ingredients
        )
        try self.saveRecipe(&localRecipe)
    }
}

enum StorageError: Error {
    case saveImageFailure
}
