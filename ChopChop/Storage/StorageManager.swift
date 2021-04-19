// swiftlint:disable file_length

import Foundation
import UIKit
import Combine

/**
 An abstraction over `AppDatabase`, `FirebaseDatabase` and `FirebaseCloudStorage` that delegates methods used by the
 application to the appropiate database manager. It also manages the translation between runtime models and database record models.
 */
struct StorageManager {
    /// Interacts with the local SQLite database using the GRDB.swift library to perform database operations.
    let appDatabase: AppDatabase
    let firebaseDatabase = FirebaseDatabase()
    let firebaseStorage = FirebaseCloudStorage()
    let cache: ChopChopCache

    init(appDatabase: AppDatabase = .shared) {
        self.appDatabase = appDatabase
        cache = .shared
    }

    // MARK: - Storage Manager: Create/Update

    /**
     Translate the given `Recipe` into its database record models before saving it.
     The `id` of the given `Recipe` is also updated after saving.
     */
    func saveRecipe(_ recipe: inout Recipe) throws {
        var recipeRecord = RecipeRecord(id: recipe.id, onlineId: recipe.onlineId,
                                        isImageUploaded: recipe.isImageUploaded,
                                        parentOnlineRecipeId: recipe.parentOnlineRecipeId,
                                        recipeCategoryId: recipe.category?.id, name: recipe.name,
                                        servings: recipe.servings, difficulty: recipe.difficulty)
        var ingredientRecords = recipe.ingredients.map { ingredient in
            RecipeIngredientRecord(recipeId: recipe.id, name: ingredient.name, quantity: ingredient.quantity.record)
        }
        var stepGraph = recipe.stepGraph

        try appDatabase.saveRecipe(&recipeRecord, ingredients: &ingredientRecords, stepGraph: &stepGraph)

        recipe.id = recipeRecord.id
    }

    /**
     Translate the given `RecipeCategory` into its database record models before saving it.
     The `id` of the given `RecipeCategory` is also updated after saving.
     */
    func saveRecipeCategory(_ recipeCategory: inout RecipeCategory) throws {
        var recipeCategoryRecord = RecipeCategoryRecord(id: recipeCategory.id, name: recipeCategory.name)

        try appDatabase.saveRecipeCategory(&recipeCategoryRecord)

        recipeCategory.id = recipeCategoryRecord.id
    }

    /**
     Translate the given `Ingredients` into their database record models before saving them.
     The underlying method called ensures the atomicity of this operation.
     The `ids` of the given `Ingredients` are also updated after saving.
     */
    func saveIngredients(_ ingredients: inout [Ingredient]) throws {
        var records: [(IngredientRecord, [IngredientBatchRecord])] = ingredients.map { ingredient in
            let ingredientRecord = IngredientRecord(id: ingredient.id,
                                                    ingredientCategoryId: ingredient.category?.id,
                                                    name: ingredient.name,
                                                    quantityType: ingredient.quantityType)
            let batchRecords = ingredient.batches.map { batch in
                IngredientBatchRecord(ingredientId: ingredient.id,
                                      expiryDate: batch.expiryDate,
                                      quantity: batch.quantity.record)
            }

            return (ingredientRecord, batchRecords)
        }

        try appDatabase.saveIngredients(&records)

        for index in ingredients.indices {
            ingredients[index].id = records[index].0.id
        }
    }

    /**
     Translate the given `Ingredient` into its database record models before saving it.
     The `id` of the given `Ingredient` is also updated after saving.
     */
    func saveIngredient(_ ingredient: inout Ingredient) throws {
        var ingredientRecord = IngredientRecord(id: ingredient.id,
                                                ingredientCategoryId: ingredient.category?.id,
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

    /**
     Translate the given `IngredientCategory` into its database record models before saving it.
     The `id` of the given `IngredientCategory` is also updated after saving.
     */
    func saveIngredientCategory(_ ingredientCategory: inout IngredientCategory) throws {
        var ingredientCategoryRecord = IngredientCategoryRecord(id: ingredientCategory.id,
                                                                name: ingredientCategory.name)

        try appDatabase.saveIngredientCategory(&ingredientCategoryRecord)

        ingredientCategory.id = ingredientCategoryRecord.id
    }

    // MARK: - StorageManager: Delete

    /**
     Deletes the `Recipes` matching the given `ids` and their corresponding images.
     */
    func deleteRecipes(ids: [Int64]) throws {
        try appDatabase.deleteRecipes(ids: ids)

        ImageStore.delete(imagesNamed: ids.map { String($0) }, inFolderNamed: StorageManager.recipeFolderName)
    }

    /**
     Deletes all `Recipes` and corresponding images
     */
    func deleteAllRecipes() throws {
        try appDatabase.deleteAllRecipes()

        ImageStore.deleteAll(inFolderNamed: StorageManager.recipeFolderName)
    }

    /**
     Deletes the `RecipeCategories` matching the given `ids`.
     */
    func deleteRecipeCategories(ids: [Int64]) throws {
        try appDatabase.deleteRecipeCategories(ids: ids)
    }

    /**
     Deletes all `RecipeCategories`.
     */
    func deleteAllRecipeCategories() throws {
        try appDatabase.deleteAllRecipeCategories()
    }

    /**
     Deletes the `Ingredients` matching the given `ids` and their corresponding images.
     */
    func deleteIngredients(ids: [Int64]) throws {
        try appDatabase.deleteIngredients(ids: ids)

        ImageStore.delete(imagesNamed: ids.map { String($0) }, inFolderNamed: StorageManager.ingredientFolderName)
    }

    /**
     Deletes all `Ingredients` and corresponding images
     */
    func deleteAllIngredients() throws {
        try appDatabase.deleteAllIngredients()

        ImageStore.deleteAll(inFolderNamed: StorageManager.ingredientFolderName)
    }

    /**
     Deletes the `IngredientCategories` matching the given `ids`.
     */
    func deleteIngredientCategories(ids: [Int64]) throws {
        try appDatabase.deleteIngredientCategories(ids: ids)
    }

    /**
     Deletes all `IngredientCategories`.
     */
    func deleteAllIngredientCategories() throws {
        try appDatabase.deleteAllIngredientCategories()
    }

    // MARK: - Storage Manager: Read

    /**
     Fetches the `Recipe` corresponding to the given `id`, or `nil` if it does not exist.
     */
    func fetchRecipe(id: Int64) throws -> Recipe? {
        try appDatabase.fetchRecipe(id: id)
    }

    func fetchRecipe(onlineId: String) throws -> Recipe? {
        try appDatabase.fetchRecipe(onlineId: onlineId)
    }

    /**
     Fetches the `RecipeCategory` corresponding to the given `name`, or `nil` if it does not exist.
     */
    func fetchRecipeCategory(name: String) throws -> RecipeCategory? {
        try appDatabase.fetchRecipeCategory(name: name)
    }

    /**
     Fetches all `Ingredients`.
     */
    func fetchIngredients() throws -> [Ingredient] {
        try appDatabase.fetchIngredients()
    }

    /**
     Fetches the `Ingredient` corresponding to the given `id`, or `nil` if it does not exist.
     */
    func fetchIngredient(id: Int64) throws -> Ingredient? {
        try appDatabase.fetchIngredient(id: id)
    }

    func fetchDownloadedRecipes(parentOnlineRecipeId: String) throws -> [Recipe] {
        try appDatabase.fetchDownloadedRecipes(parentOnlineRecipeId: parentOnlineRecipeId)
    }

    // MARK: - Database Access: Publishers

    /**
     A publisher that emits the `Recipe` corresponding to the given `id`, or `nil` if it does not exist.
     */
    func recipePublisher(id: Int64) -> AnyPublisher<Recipe?, Error> {
        appDatabase.recipePublisher(id: id)
    }

    /**
     A publisher that emits the `RecipeInfo` matching the given `query`, `categoryIds` and `Ingredients`.
     */
    func recipesPublisher(query: String,
                          categoryIds: [Int64?],
                          ingredients: [String]) -> AnyPublisher<[RecipeInfo], Error> {
        appDatabase.recipesPublisher(query: query, categoryIds: categoryIds, ingredients: ingredients)
            .map { $0.map { RecipeInfo(id: $0.id, name: $0.name, servings: $0.servings, difficulty: $0.difficulty) } }
            .eraseToAnyPublisher()
    }

    /**
     A publisher that emits all `RecipeCategories`.
     */
    func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Error> {
        appDatabase.recipeCategoriesPublisher()
            .map { $0.compactMap { try? RecipeCategory(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    /**
     A publisher that emits the names of the `RecipeIngredients` found in the given `categoryIds`.
     */
    func recipeIngredientsPublisher(categoryIds: [Int64?]) -> AnyPublisher<[String], Error> {
        appDatabase.recipeIngredientsPublisher(categoryIds: categoryIds)
            .map { Array(Set($0.map { $0.name })).sorted() }
            .eraseToAnyPublisher()
    }

    /**
     A publisher that emits the `Ingredient` corresponding to the given `id`, or `nil` if it does not exist.
     */
    func ingredientPublisher(id: Int64) -> AnyPublisher<Ingredient?, Error> {
        appDatabase.ingredientPublisher(id: id)
    }

    /**
     A publisher that emits all `IngredientInfos`.
     */
    func ingredientsPublisher() -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsPublisher()
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name, quantity: String($0.totalQuantityDescription)) } }
            .eraseToAnyPublisher()
    }

    /**
     A publisher that emits the `IngredientInfos` matching the given `query` and `categoryIds`.
     */
    func ingredientsPublisher(query: String, categoryIds: [Int64?]) -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsPublisher(query: query, categoryIds: categoryIds)
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name, quantity: String($0.totalQuantityDescription)) } }
            .eraseToAnyPublisher()
    }

    /**
     A publisher that emits the `IngredientInfos` matching the given `query`, `categoryIds`
     and expiring between `expiresAfter` and `expiresBefore`.
     */
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

    /**
     A publisher that emits all `IngredientCategoryRecords`.
     */
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

    func fetchRecipeImage(name: String) -> UIImage? {
        ImageStore.fetch(imageNamed: name, inFolderNamed: StorageManager.recipeFolderName)
    }

    func saveRecipeImage(_ image: UIImage, name: String) throws {
        do {
            try ImageStore.save(image: image, name: name, inFolderNamed: StorageManager.recipeFolderName)
        } catch {
            throw StorageError.saveImageFailure
        }
    }

    func deleteIngredientImage(name: String) {
        ImageStore.delete(imageNamed: name, inFolderNamed: StorageManager.ingredientFolderName)
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

    // MARK: - Storage Manager: Create/Update

    /**
     Creates OnlineRecipe in Firebase and uploads Recipe's image if any.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func addOnlineRecipe(recipe: inout Recipe, userId: String, completion: @escaping (Error?) -> Void) throws {
        let cuisine = recipe.category?.name
        let ingredients = recipe.ingredients.map({
            OnlineIngredientRecord(name: $0.name, quantity: $0.quantity.record)
        })
        let stepGraph = recipe.stepGraph
        let nodes = stepGraph.nodes.map({
            OnlineStepRecord(id: $0.id.uuidString, content: $0.label.content)
        })

        let edgeRecords = stepGraph.edges.map({
            OnlineStepEdgeRecord(sourceStepId: $0.source.id.uuidString, destinationStepId: $0.destination.id.uuidString)
        })

        let recipeRecord = OnlineRecipeRecord(
            name: recipe.name,
            creatorId: userId,
            parentOnlineRecipeId: recipe.parentOnlineRecipeId,
            servings: recipe.servings,
            cuisine: cuisine,
            difficulty: recipe.difficulty,
            ingredients: ingredients,
            steps: nodes,
            stepEdges: edgeRecords
        )

        guard let id = recipe.id else {
            return
        }

        let recipeImage = self.fetchRecipeImage(name: String(id))

        let onlineId = try firebaseDatabase.addOnlineRecipe(recipe: recipeRecord, completion: completion)

        recipe.onlineId = onlineId
        recipe.isImageUploaded = true
        try self.saveRecipe(&recipe)

        guard let fetchedRecipeImage = recipeImage else {
            return
        }
        firebaseStorage.uploadImage(image: fetchedRecipeImage, name: onlineId)
    }

    /**
     Updates OnlineRecipe in Firebase
     Uploads Recipe's image only if necessary
     Deletes OnlineRecipe's image if local Recipe's image is deleted
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func updateOnlineRecipe(recipe: Recipe, userId: String, completion: @escaping (Error?) -> Void) throws {

        let cuisine = recipe.category?.name
        let ingredients = recipe.ingredients.map({
            OnlineIngredientRecord(name: $0.name, quantity: $0.quantity.record)
        })
        let stepGraph = recipe.stepGraph
        let nodes = stepGraph.nodes.map({
            OnlineStepRecord(id: $0.id.uuidString, content: $0.label.content)
        })

        let edgeRecords = stepGraph.edges.map({
            OnlineStepEdgeRecord(sourceStepId: $0.source.id.uuidString, destinationStepId: $0.destination.id.uuidString)
        })

        let recipeRecord = OnlineRecipeRecord(
            id: recipe.onlineId,
            name: recipe.name,
            creatorId: userId,
            parentOnlineRecipeId: recipe.parentOnlineRecipeId,
            servings: recipe.servings,
            cuisine: cuisine,
            difficulty: recipe.difficulty,
            ingredients: ingredients,
            steps: nodes,
            stepEdges: edgeRecords
        )

        guard let id = recipe.id, let onlineId = recipe.onlineId else {
            return
        }

        let isImageUploaded = recipe.isImageUploaded
        let image = fetchRecipeImage(name: String(id))

        firebaseDatabase.updateOnlineRecipe(recipe: recipeRecord,
                                            isImageUploadedAlready: isImageUploaded,
                                            completion: completion)

        guard !isImageUploaded else {
            return
        }

        if image == nil {
            firebaseStorage.deleteImage(name: onlineId)
            cache.onlineRecipeImageCache.removeValue(forKey: onlineId)
        } else if let image = image {
            firebaseStorage.uploadImage(image: image, name: onlineId)
        }

        var recipe = recipe
        recipe.isImageUploaded = true
        try saveRecipe(&recipe)
    }

    /**
     Add a rating of an OnlineRecipe. Updates both OnlineRecipe's ratings and involved User's user ratings.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func addOnlineRecipeRating(recipeId: String, userId: String, rating: RatingScore, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.addUserRecipeRating(userId: userId,
                                             rating: UserRating(recipeOnlineId: recipeId, score: rating),
                                             completion: completion)
        firebaseDatabase.addOnlineRecipeRating(onlineRecipeId: recipeId,
                                         rating: RecipeRating(userId: userId, score: rating),
                                         completion: completion)
    }

    /**
     Updates a rating of an OnlineRecipe. Updates both OnlineRecipe's ratings and involved User's user ratings.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func updateOnlineRecipeRating(recipeId: String, oldRating: RecipeRating, newRating: RecipeRating,
                      completion: @escaping (Error?) -> Void) {
        firebaseDatabase.updateOnlineRecipeRating(recipeId: recipeId,
                                            oldRating: oldRating,
                                            newRating: newRating,
                                            completion: completion)
        firebaseDatabase.updateUserRating(userId: newRating.userId,
                                          oldRating: UserRating(recipeOnlineId: recipeId, score: oldRating.score),
                                          newRating: UserRating(recipeOnlineId: recipeId, score: newRating.score),
                                          completion: completion)
    }

    /**
     Adds a user of that name.
     Signals completion via a completion handler and returns the userId of the new user and error in completion handler if any.
     */
    func addUser(name: String, completion: @escaping (String?, Error?) -> Void) throws {
        try firebaseDatabase.addUser(user: UserRecord(name: name, followees: [], ratings: []), completion: completion)
    }

    /**
     Adds a followee of that followeeId to the user of that userId
     Signals completion via a completion handler and returns an error in completion handler if any.
     */
    func addFollowee(userId: String, followeeId: String, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.addFollowee(userId: userId, followeeId: followeeId, completion: completion)
    }

    /**
     Overwrites forked local Recipe with parent OnlineRecipe
     */
    func updateForkedRecipes(forked: Recipe, original: OnlineRecipe) throws {
        var cuisineCategory: RecipeCategory?
        if let cuisine = original.cuisine {
            cuisineCategory = try? self.fetchRecipeCategory(name: cuisine)
        }

        var localRecipe = try Recipe(
            id: forked.id,
            onlineId: forked.onlineId,
            parentOnlineRecipeId: forked.parentOnlineRecipeId,
            name: forked.name,
            category: cuisineCategory,
            servings: original.servings,
            difficulty: original.difficulty,
            ingredients: original.ingredients,
            stepGraph: original.stepGraph
        )

        try self.saveRecipe(&localRecipe)
    }

    /**
     Save OnlineRecipe to local database.
     Signals completion via a completion handler and returns the error in completion handler if any.
     */
    func downloadRecipe(newName: String, recipe: OnlineRecipe, completion: @escaping (Error?) -> Void) throws {
        var cuisine: RecipeCategory?
        if let cuisineName = recipe.cuisine {
            cuisine = try fetchRecipeCategory(name: cuisineName)
        }

        // must be both original owner and not have any local recipes currently connected to this online recipe
        // in order to establish a connection to this online recipe after download
        let isRecipeOwner = recipe.creatorId == UserDefaults.standard.string(forKey: "creatorId")
        let isRecipeAlreadyConnected = (try? fetchRecipe(onlineId: recipe.id)) != nil
        let newOnlineId = (isRecipeOwner && !isRecipeAlreadyConnected) ? recipe.id : nil

        var localRecipe = try Recipe(
            onlineId: newOnlineId,
            isImageUploaded: false,
            parentOnlineRecipeId: isRecipeOwner ? nil : recipe.id,
            name: newName,
            category: cuisine,
            servings: recipe.servings,
            difficulty: recipe.difficulty,
            ingredients: recipe.ingredients,
            stepGraph: recipe.stepGraph
        )
        try? self.saveRecipe(&localRecipe)

        firebaseStorage.fetchImage(name: recipe.id) { data, err in
            guard let data = data, err == nil else {
                completion(err)
                return
            }
            let image = UIImage(data: data)
            guard let fetchedImage = image, let id = localRecipe.id else {
                return
            }
            try? self.saveRecipeImage(fetchedImage, name: String(id))
            completion(err)
        }
    }

    // MARK: - Storage Manager: Delete

    /**
     Delete an OnlineRecipe, effectively unpublishing the recipe. Removes the link from the respective local Recipe to the OnlineRecipe, if any.
     Signals completion via a completion handler and returns an error in completion handler if any.
     */
    func removeOnlineRecipe(recipe: OnlineRecipe, completion: @escaping (Error?) -> Void) throws {
        try firebaseDatabase.removeOnlineRecipe(recipeId: recipe.id, completion: completion)
        for rating in recipe.ratings {
            firebaseDatabase.removeUserRecipeRating(
                userId: rating.userId,
                rating: UserRating(recipeOnlineId: recipe.id, score: rating.score),
                completion: completion
            )
        }
        firebaseStorage.deleteImage(name: recipe.id)

        cache.onlineRecipeCache.removeValue(forKey: recipe.id)
        cache.onlineRecipeImageCache[recipe.id] = nil

        // might alr have deleted local recipe
        let fetchedRecipe = try? self.fetchRecipe(onlineId: recipe.id)
        guard var localRecipe = fetchedRecipe else {
            return
        }
        localRecipe.onlineId = nil
        localRecipe.isImageUploaded = false
        try self.saveRecipe(&localRecipe)
    }

    /**
     Removes a followee of that followeeId from user of that userId
     Signals completion via a completion handler and returns an error in completion handler if any.
     */
    func removeFollowee(userId: String, followeeId: String, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.removeFollowee(userId: userId, followeeId: followeeId, completion: completion)
    }

    /**
     Removes a rating of an OnlineRecipe. Updates both OnlineRecipe's ratings and involved User's user ratings.
     Signals completion via a completion handler and returns error in completion handler if any.
     */
    func removeOnlineRecipeRating(recipeId: String, rating: RecipeRating, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.removeRecipeRating(onlineRecipeId: recipeId, rating: rating, completion: completion)
        firebaseDatabase.removeUserRecipeRating(
            userId: rating.userId,
            rating: UserRating(recipeOnlineId: recipeId, score: rating.score), completion: completion)
    }

    // MARK: - Storage Manager: Fetch

    /**
     Fetches OnlineRecipe of that id
     Signals completion via a completion handler and returns the OnlineRecipe and error in completion handler if any.
     */
    func fetchOnlineRecipe(id: String, completion: @escaping (OnlineRecipe?, Error?) -> Void) {
        firebaseDatabase.fetchOnlineRecipeInfo(id: id) { recipeInfoRecord, err in
            guard let recipeInfoRecord = recipeInfoRecord, err == nil else {
                completion(nil, err)
                return
            }

            if let updatedAt = recipeInfoRecord.updatedAt,
               let cachedOnlineRecipe = cache.onlineRecipeCache.getEntityIfCachedAndValid(id: id,
                                                                                          updatedDate: updatedAt) {
                completion(cachedOnlineRecipe, nil)
                return
            }

            firebaseDatabase.fetchOnlineRecipe(id: id) { onlineRecipeRecord, err in
                guard let recipeRecord = onlineRecipeRecord,
                      let onlineRecipe = try? OnlineRecipe(from: recipeRecord, info: recipeInfoRecord),
                      err == nil else {
                    completion(nil, err)
                    return
                }
                cache.onlineRecipeCache[id] = onlineRecipe
                completion(onlineRecipe, nil)
            }
        }
    }

    /**
     Fetches user of that id
     Signals completion via a completion handler and returns the User and error in completion handler if any.
     */
    func fetchUser(id: String, completion: @escaping (User?, Error?) -> Void) {
        firebaseDatabase.fetchUserInfo(id: id) { userInfoRecord, err in
            guard let userInfoRecord = userInfoRecord, err == nil else {
                completion(nil, err)
                return
            }

            if let updatedAt = userInfoRecord.updatedAt,
               let cachedUser = cache.userCache.getEntityIfCachedAndValid(id: id, updatedDate: updatedAt) {
                completion(cachedUser, nil)
                return
            }

            firebaseDatabase.fetchUser(id: id) { userRecord, err in
                guard let userRecord = userRecord,
                      let user = User(from: userRecord, infoRecord: userInfoRecord),
                      err == nil else {
                    completion(nil, err)
                    return
                }
                cache.userCache[id] = user
                completion(user, nil)
            }
        }
    }

    /**
     Fetches all OnlineRecipes
     Signals completion via a completion handler and returns the OnlineRecipes and error in completion handler if any.
     */
    func fetchAllOnlineRecipes(completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        firebaseDatabase.fetchAllOnlineRecipeInfos { recipeInfoRecords, err in
            fetchOnlineRecipes(recipeInfoRecords: recipeInfoRecords, err: err, completion: completion)
        }
    }

    /**
     Fetches OnlineRecipe whose creatorId is included in userIds
     Signals completion via a completion handler and returns the OnlineRecipes and error in completion handler if any.
     */
    func fetchOnlineRecipes(userIds: [String], completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        firebaseDatabase.fetchOnlineRecipeInfos(userIds: userIds) { recipeInfoRecords, err in
            fetchOnlineRecipes(recipeInfoRecords: recipeInfoRecords, err: err, completion: completion)
        }
    }

    /**
     Fetches all Users
     Signals completion via a completion handler and returns the users and error in completion handler if any.
     */
    func fetchAllUsers(completion: @escaping ([User], Error?) -> Void) {
        firebaseDatabase.fetchAllUserInfos { userInfoRecords, err in
            fetchUsers(userInfoRecords: userInfoRecords, err: err, completion: completion)
        }
    }

    /**
     Fetches all Users whos ids are in ids
     Signals completion via a completion handler and returns the users and error in completion handler if any.
     */
    func fetchUsers(ids: [String], completion: @escaping ([User], Error?) -> Void) {
        firebaseDatabase.fetchUserInfos(ids: ids) { userInfoRecords, err in
            fetchUsers(userInfoRecords: userInfoRecords, err: err, completion: completion)
        }
    }

    func fetchOnlineRecipeImage(recipeId: String, completion: @escaping (Data?, Error?) -> Void) {
        firebaseDatabase.fetchOnlineRecipeInfo(id: recipeId) { recipeInfoRecord, err in
            guard let recipeInfoRecord = recipeInfoRecord, err == nil else {
                completion(nil, err)
                return
            }

            guard let imageUpdatedAt = recipeInfoRecord.imageUpdatedAt else {
                completion(nil, err)
                cache.onlineRecipeImageCache[recipeId] = nil
                return
            }

            if let data = cache.onlineRecipeImageCache.getEntityIfCachedAndValid(id: recipeId,
                                                                                 updatedDate: imageUpdatedAt) {
                completion(data.data, nil)
                return
            }

            firebaseStorage.fetchImage(name: recipeId) { data, err in
                guard let data = data, err == nil else {
                    cache.onlineRecipeImageCache.removeValue(forKey: recipeId)
                    completion(nil, err)
                    return
                }
                cache.onlineRecipeImageCache.insert(CachableData(updatedAt: imageUpdatedAt, data: data),
                                                    forKey: recipeId)
                completion(data, nil)
            }
        }
    }

    // MARK: - Storage Manager: Listen

    /**
     Listens to the details of a single user.
     This operation is expensive as it fetches the user whenever there is a change, and should be used selectively.
     */
    func userListener(id: String, onChange: @escaping (User) -> Void) {
        firebaseDatabase.userListener(id: id) { userRecord in
            // Note: cannot use UserRecord because UserInfoRecord is not fetched
            guard let user = try? User(id: id, name: userRecord.name, followees: userRecord.followees,
                                       ratings: userRecord.ratings, createdAt: Date(), updatedAt: Date()) else {
                return
            }
            onChange(user)
        }
    }

    /**
     Fetches the OnlineRecipes whose ids are in recipeInfoRecords.
     Each OnlineRecipeInfoRecord is checked against the corresponding OnlineRecipe in cache,
     and only OnlineRecipes that are not in cache or are outdated are fetched from Firebase.
     Signals completion via a completion handler and returns the OnlineRecipes and error in completion handler if any.
     */
    private func fetchOnlineRecipes(recipeInfoRecords: [String: OnlineRecipeInfoRecord], err: Error?,
                                    completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        guard !recipeInfoRecords.isEmpty, err == nil else {
            completion([], err)
            return
        }

        // figure out which recipes actually need to fetch
        let recipeIdsToFetch = recipeInfoRecords.keys.filter { recipeInfoId in
            guard let updatedAt = recipeInfoRecords[recipeInfoId]?.updatedAt,
                  cache.onlineRecipeCache.getEntityIfCachedAndValid(id: recipeInfoId,
                                                                    updatedDate: updatedAt) != nil else {
                return true
            }
            return false
        }

        // if no recipes to fetch, just collate from cache and return from function
        guard !recipeIdsToFetch.isEmpty else {
            let recipes = recipeInfoRecords.keys.compactMap { cache.onlineRecipeCache[$0]
            }
            completion(recipes, nil)
            return
        }

        firebaseDatabase.fetchOnlineRecipes(ids: recipeIdsToFetch) { onlineRecipeRecords, err in
            if let err = err {
                completion([], err)
                return
            }

            for onlineRecipeRecord in onlineRecipeRecords {
                guard let id = onlineRecipeRecord.id,
                      let recipeInfoRecord = recipeInfoRecords[id],
                      let onlineRecipe = try? OnlineRecipe(from: onlineRecipeRecord, info: recipeInfoRecord) else {
                    continue
                }
                cache.onlineRecipeCache.insert(onlineRecipe, forKey: id)
            }

            let recipes = recipeInfoRecords.keys.compactMap { cache.onlineRecipeCache[$0] }
            completion(recipes, nil)
        }
    }

    /**
     Fetches the Users whose ids are in userInfoRecords.
     Each UserInfoRecord is checked against the corresponding User in cache,
     and only Users that are not in cache or are outdated are fetched from Firebase.
     Signals completion via a completion handler and returns the Users and error in completion handler if any.
     */
    private func fetchUsers(userInfoRecords: [String: UserInfoRecord], err: Error?,
                            completion: @escaping ([User], Error?) -> Void) {
        guard !userInfoRecords.isEmpty, err == nil else {
            completion([], err)
            return
        }

        let userIdsToFetch = userInfoRecords.keys.filter { userInfoId in
            guard let updatedAt = userInfoRecords[userInfoId]?.updatedAt,
                  cache.userCache.getEntityIfCachedAndValid(id: userInfoId, updatedDate: updatedAt) != nil else {
                return true
            }
            return false
        }

        guard !userIdsToFetch.isEmpty else {
            let users = userInfoRecords.keys.compactMap { cache.userCache[$0] }
            completion(users, nil)
            return
        }

        firebaseDatabase.fetchUsers(ids: userIdsToFetch) { userRecords, err in
            if let err = err {
                completion([], err)
                return
            }

            for userRecord in userRecords {
                guard let id = userRecord.id,
                      let userInfoRecord = userInfoRecords[id],
                      let user = User(from: userRecord, infoRecord: userInfoRecord) else {
                    continue
                }
                cache.userCache.insert(user, forKey: id)
            }

            let users = userInfoRecords.keys.compactMap { cache.userCache[$0] }
            completion(users, nil)

        }
    }
}

enum StorageError: Error {
    case saveImageFailure
}
