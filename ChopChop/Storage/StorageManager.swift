// swiftlint:disable file_length

import Foundation
import UIKit
import Combine

struct StorageManager {
    let appDatabase: AppDatabase
    let firebaseDatabase = FirebaseDatabase()
    let firebaseStorage = FirebaseCloudStorage()
    let cache: ChopChopCache

    init(appDatabase: AppDatabase = .shared) {
        self.appDatabase = appDatabase
        cache = .shared
    }

    // MARK: - Storage Manager: Create/Update

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

    func saveRecipeCategory(_ recipeCategory: inout RecipeCategory) throws {
        var recipeCategoryRecord = RecipeCategoryRecord(id: recipeCategory.id, name: recipeCategory.name)

        try appDatabase.saveRecipeCategory(&recipeCategoryRecord)

        recipeCategory.id = recipeCategoryRecord.id
    }

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

    func saveIngredientCategory(_ ingredientCategory: inout IngredientCategory) throws {
        var ingredientCategoryRecord = IngredientCategoryRecord(id: ingredientCategory.id,
                                                                name: ingredientCategory.name)

        try appDatabase.saveIngredientCategory(&ingredientCategoryRecord)

        ingredientCategory.id = ingredientCategoryRecord.id
    }

    // MARK: - StorageManager: Delete

    func deleteRecipes(ids: [Int64]) throws {
        try appDatabase.deleteRecipes(ids: ids)

        ImageStore.delete(imagesNamed: ids.map { String($0) }, inFolderNamed: StorageManager.recipeFolderName)
    }

    func deleteAllRecipes() throws {
        try appDatabase.deleteAllRecipes()

        ImageStore.deleteAll(inFolderNamed: StorageManager.recipeFolderName)
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

    func fetchRecipe(onlineId: String) throws -> Recipe? {
        try appDatabase.fetchRecipe(onlineId: onlineId)
    }

    func fetchRecipeCategory(name: String) throws -> RecipeCategory? {
        try appDatabase.fetchRecipeCategory(name: name)
    }

    func fetchIngredients() throws -> [Ingredient] {
        try appDatabase.fetchIngredients()
    }

    func fetchIngredient(id: Int64) throws -> Ingredient? {
        try appDatabase.fetchIngredient(id: id)
    }

    func fetchDownloadedRecipes(parentOnlineRecipeId: String) throws -> [Recipe] {
        try appDatabase.fetchDownloadedRecipes(parentOnlineRecipeId: parentOnlineRecipeId)
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
            .map { $0.compactMap { try? RecipeCategory(id: $0.id, name: $0.name) } }
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

    func deleteRecipeImage(name: String, id: Int64) throws {
        guard var recipe = try fetchRecipe(id: id) else {
            return
        }
        recipe.isImageUploaded = nil
        try saveRecipe(&recipe)
        ImageStore.delete(imageNamed: name, inFolderNamed: StorageManager.recipeFolderName)
    }

    func fetchRecipeImage(name: String) -> UIImage? {
        ImageStore.fetch(imageNamed: name, inFolderNamed: StorageManager.recipeFolderName)
    }

    func saveRecipeImage(_ image: UIImage, id: Int64, name: String) throws {
        do {
            let originalImage = fetchRecipeImage(name: name)
            let isSameImage = originalImage?.pngData() == image.pngData()
            guard var recipe = try fetchRecipe(id: id), !isSameImage else {
                return
            }
            recipe.isImageUploaded = false
            try saveRecipe(&recipe)

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

    // publish your local recipe online
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
            creator: userId,
            parentOnlineRecipeId: recipe.parentOnlineRecipeId,
            servings: recipe.servings,
            cuisine: cuisine,
            difficulty: recipe.difficulty,
            ingredients: ingredients,
            steps: nodes,
            stepEdges: edgeRecords
        )

        guard let id = recipe.id else {
            assertionFailure("Should have id")
            return
        }

        let recipeImage = self.fetchRecipeImage(name: String(id))

        let onlineId = try firebaseDatabase.addOnlineRecipe(recipe: recipeRecord, isImageExist: recipeImage != nil, completion: completion)

        recipe.onlineId = onlineId
        recipe.isImageUploaded = (recipeImage == nil ? nil : true)
        try self.saveRecipe(&recipe)

        guard let fetchedRecipeImage = recipeImage else {
            return
        }
        firebaseStorage.uploadImage(image: fetchedRecipeImage, name: onlineId)

        // note: don't update cache because don't know onlineRecipeId
    }

    // update details of published recipe (note that ratings cant be updated here)
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
            creator: userId,
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

        firebaseDatabase.updateOnlineRecipe(recipe: recipeRecord, isImageUploadedAlready: isImageUploaded, completion: completion)

        if isImageUploaded == nil {
            firebaseStorage.deleteImage(name: onlineId)
            cache.onlineRecipeImageCache[onlineId] = nil
            return
        } else if isImageUploaded == false {
            return
        } else {
            guard let image = fetchRecipeImage(name: String(id)) else {
                return
            }

            firebaseStorage.uploadImage(image: image, name: onlineId)
            var recipe = recipe
            recipe.isImageUploaded = true
            try saveRecipe(&recipe)
        }

        // note: don't update cache because don't know updatedAt timestamps
    }

    // rate a recipe
    func rateRecipe(recipeId: String, userId: String, rating: RatingScore, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.addUserRecipeRating(userId: userId, rating: UserRating(recipeOnlineId: recipeId, score: rating), completion: completion)
        firebaseDatabase.addRecipeRating(onlineRecipeId: recipeId, rating: RecipeRating(userId: userId, score: rating), completion: completion)
    }

    // change the rating of a recipe you have rated before
    func rerateRecipe(recipeId: String, oldRating: RecipeRating, newRating: RecipeRating, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.updateRecipeRating(recipeId: recipeId, oldRating: oldRating, newRating: newRating, completion: completion)
        firebaseDatabase.updateUserRating(userId: newRating.userId,
                                          oldRating: UserRating(recipeOnlineId: recipeId, score: oldRating.score),
                                          newRating: UserRating(recipeOnlineId: recipeId, score: newRating.score), completion: completion)
    }

    // this should only be called once when the app first launched
    func addUser(name: String, completion: @escaping (Error?) -> Void) throws -> String {
        try firebaseDatabase.addUser(user: UserRecord(name: name, followees: [], ratings: []), completion: completion)
    }

    // follow someone
    func addFollowee(userId: String, followeeId: String, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.addFollowee(userId: userId, followeeId: followeeId, completion: completion)
    }

    // MARK: - Storage Manager: Delete

    // unpublish a recipe through the online interface
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
        localRecipe.isImageUploaded = nil
        try self.saveRecipe(&localRecipe)
    }

    // unfollow someone
    func removeFollowee(userId: String, followeeId: String, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.removeFollowee(userId: userId, followeeId: followeeId, completion: completion)
    }

    // remove rating of a recipe you rated
    func unrateRecipe(recipeId: String, rating: RecipeRating, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.removeRecipeRating(onlineRecipeId: recipeId, rating: rating, completion: completion)
        firebaseDatabase.removeUserRecipeRating(
            userId: rating.userId,
            rating: UserRating(recipeOnlineId: recipeId, score: rating.score), completion: completion)
    }

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

    // MARK: - Storage Manager: Fetch

    // fetch the details of a single recipe
    func fetchOnlineRecipe(id: String, completion: @escaping (OnlineRecipe?, Error?) -> Void) {
        firebaseDatabase.fetchOnlineRecipeInfo(id: id) { recipeInfoRecord, err in
            guard let recipeInfoRecord = recipeInfoRecord, err == nil else {
                completion(nil, err)
                return
            }

            if let updatedAt = recipeInfoRecord.updatedAt,
               let cachedOnlineRecipe = cache.onlineRecipeCache.getEntityIfCachedAndValid(id: id, updatedDate: updatedAt) {
                completion(cachedOnlineRecipe, nil)
                return
            }

            firebaseDatabase.fetchOnlineRecipe(id: id) { onlineRecipeRecord, err in
                guard let recipeRecord = onlineRecipeRecord,
                      let onlineRecipe = try? OnlineRecipe(from: recipeRecord, info: recipeInfoRecord), err == nil else {
                    completion(nil, err)
                    return
                }
                cache.onlineRecipeCache[id] = onlineRecipe
                completion(onlineRecipe, nil)
            }

        }
    }

    // fetch the details of a single user
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
                guard let userRecord = userRecord, let user = User(from: userRecord, infoRecord: userInfoRecord), err == nil else {
                    completion(nil, err)
                    return
                }
                cache.userCache[id] = user
                completion(user, nil)
            }

        }
    }

    // fetch all recipes published by everyone
    func fetchAllOnlineRecipes(completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        firebaseDatabase.fetchAllOnlineRecipeInfos { recipeInfoRecords, err in
            fetchOnlineRecipes(recipeInfoRecords: recipeInfoRecords, err: err, completion: completion)
        }
    }

    // Can be used to fetch all your own recipes or recipes of several selected users
    func fetchOnlineRecipes(userIds: [String], completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        firebaseDatabase.fetchOnlineRecipeInfos(userIds: userIds) { recipeInfoRecords, err in
            fetchOnlineRecipes(recipeInfoRecords: recipeInfoRecords, err: err, completion: completion)
        }

    }

    // Fetch details of all users in the system
    func fetchAllUsers(completion: @escaping ([User], Error?) -> Void) {
        firebaseDatabase.fetchAllUserInfos { userInfoRecords, err in
            fetchUsers(userInfoRecords: userInfoRecords, err: err, completion: completion)
        }
    }

    // Fetch details of all users in the system
    func fetchUsers(ids: [String], completion: @escaping ([User], Error?) -> Void) {
        firebaseDatabase.fetchUserInfos(ids: ids) { userInfoRecords, err in
            fetchUsers(userInfoRecords: userInfoRecords, err: err, completion: completion)
        }
    }

    // download an online recipe to local
    func downloadRecipe(newName: String, recipe: OnlineRecipe, completion: @escaping (Error?) -> Void) throws {
        var cuisine: RecipeCategory?
        if let cuisineName = recipe.cuisine {
            cuisine = try fetchRecipeCategory(name: cuisineName)
        }

        // must be both original owner and not have any local recipes currently connected to this online recipe
        // in order to establish a connection to this online recipe after download
        let isRecipeOwner = recipe.userId == UserDefaults.standard.string(forKey: "userId")
        let isRecipeAlreadyConnected = (try? fetchRecipe(onlineId: recipe.id)) != nil
        let newOnlineId = (isRecipeOwner && !isRecipeAlreadyConnected) ? recipe.id : nil

        var localRecipe = try Recipe(
            onlineId: newOnlineId,
            isImageUploaded: false, // TODO check
            parentOnlineRecipeId: isRecipeOwner ? nil : recipe.id,
            name: newName,
            category: cuisine,
            servings: recipe.servings,
            difficulty: recipe.difficulty,
            ingredients: recipe.ingredients,
            stepGraph: recipe.stepGraph
        )
        try self.saveRecipe(&localRecipe)

        firebaseStorage.fetchImage(name: recipe.id) { data, err in
            guard let data = data, err == nil else {
                completion(err)
                return
            }
            let image = UIImage(data: data)
            guard let fetchedImage = image, let id = localRecipe.id else {
                return
            }
            try? self.saveRecipeImage(fetchedImage, id: id, name: String(id))

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

            guard let lastFetchedImageDate = cache.onlineRecipeCache[recipeId]?.imageUpdatedAt,
                  lastFetchedImageDate >= imageUpdatedAt else {
                firebaseStorage.fetchImage(name: recipeId) { data, err in
                    guard let data = data, err == nil else {
                        completion(nil, err)
                        return
                    }
                    cache.onlineRecipeImageCache[recipeId] = data
                    cache.onlineRecipeCache[recipeId]?.imageUpdatedAt = imageUpdatedAt
                    completion(data, nil)
                }
                return
            }

            let data = cache.onlineRecipeImageCache[recipeId]
            completion(data, nil)
            return

        }

    }

    // MARK: - Storage Manager: Listen

    // listen to the details of a single user
    // use case: own user object
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

    private func fetchOnlineRecipes(recipeInfoRecords: [String: OnlineRecipeInfoRecord], err: Error?,
                                    completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        guard !recipeInfoRecords.isEmpty, err == nil else {
            completion([], err)
            return
        }

        // figure out which recipes actually need to fetch
        let recipeIdsToFetch = recipeInfoRecords.keys.filter { recipeInfoId in
            guard let updatedAt = recipeInfoRecords[recipeInfoId]?.updatedAt,
                  let _ = cache.onlineRecipeCache.getEntityIfCachedAndValid(id: recipeInfoId, updatedDate: updatedAt) else {
                return true
            }
            return false
        }

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

    private func fetchUsers(userInfoRecords: [String: UserInfoRecord], err: Error?,
                            completion: @escaping ([User], Error?) -> Void) {
        guard !userInfoRecords.isEmpty, err == nil else {
            completion([], err)
            return
        }

        let userIdsToFetch = userInfoRecords.keys.filter { userInfoId in
            guard let updatedAt = userInfoRecords[userInfoId]?.updatedAt,
                  let _ = cache.userCache.getEntityIfCachedAndValid(id: userInfoId, updatedDate: updatedAt) else {
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
                      let userInfoRecord = userInfoRecords[id], let user = User(from: userRecord, infoRecord: userInfoRecord) else {
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
