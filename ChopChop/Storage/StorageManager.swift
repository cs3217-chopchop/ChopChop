import Foundation
import UIKit
import Combine

struct StorageManager {
    let appDatabase: AppDatabase
    let firebaseDatabase = FirebaseDatabase()
    let firebaseStorage = FirebaseCloudStorage()
    let firebaseCache: FirebaseCache // TODO rename to cache

    init(appDatabase: AppDatabase = .shared) {
        self.appDatabase = appDatabase
        firebaseCache = .shared
    }

    // MARK: - Storage Manager: Create/Update

    func saveRecipe(_ recipe: inout Recipe) throws {
        var recipeRecord = RecipeRecord(id: recipe.id, onlineId: recipe.onlineId,
                                        recipeCategoryId: recipe.recipeCategoryId, name: recipe.name,
                                        servings: recipe.servings, difficulty: recipe.difficulty)
        var ingredientRecords = recipe.ingredients.map { ingredient in
            RecipeIngredientRecord(recipeId: recipe.id, name: ingredient.name, quantity: ingredient.quantity.record)
        }
        var graph = recipe.stepGraph

        try appDatabase.saveRecipe(
            &recipeRecord,
            ingredients: &ingredientRecords,
            graph: &graph)

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

    // MARK: - Storage Manager: Create/Update

    // publish your local recipe online
    func createOnlineRecipe(recipe: inout Recipe, userId: String) throws {
        var cuisine: String?
        if let categoryId = recipe.recipeCategoryId {
            cuisine = try? fetchRecipeCategory(id: categoryId)?.name
        }
        let ingredients = recipe.ingredients.map({
            OnlineIngredientRecord(name: $0.name, quantity: $0.quantity.record)
        })
        let stepGraph = recipe.stepGraph
        let nodes = stepGraph.nodes.map({
            $0.label.content
        })
        let edgeRecords = stepGraph.edges.map({
            OnlineStepEdgeRecord(sourceStep: $0.source.label.content, destinationStep: $0.destination.label.content)
        })
        let recipeRecord = OnlineRecipeRecord(
            name: recipe.name,
            creator: userId,
            servings: recipe.servings,
            cuisine: cuisine,
            difficulty: recipe.difficulty,
            ingredients: ingredients,
            steps: nodes,
            stepEdges: edgeRecords
        )
        let onlineId = try firebaseDatabase.addRecipe(recipe: recipeRecord)
        recipe.onlineId = onlineId
        try self.saveRecipe(&recipe)

        let recipeImage = self.fetchRecipeImage(name: recipe.name)
        guard let fetchedRecipeImage = recipeImage else {
            return
        }
        firebaseStorage.uploadImage(image: fetchedRecipeImage, name: onlineId)
    }

    // update details of published recipe (note that ratings cant be updated here)
    func updateOnlineRecipe(recipe: Recipe, userId: String) {
        var cuisine: String?
        if let categoryId = recipe.recipeCategoryId {
            cuisine = try? fetchRecipeCategory(id: categoryId)?.name
        }
        let ingredients = recipe.ingredients.map({
            OnlineIngredientRecord(name: $0.name, quantity: $0.quantity.record)
        })
        let stepGraph = recipe.stepGraph
        let nodes = stepGraph.nodes.map({
            $0.label.content
        })
        let edgeRecords = stepGraph.edges.map({
            OnlineStepEdgeRecord(sourceStep: $0.source.label.content, destinationStep: $0.destination.label.content)
        })
        let recipeRecord = OnlineRecipeRecord(
            id: recipe.onlineId,
            name: recipe.name,
            creator: userId,
            servings: recipe.servings,
            cuisine: cuisine,
            difficulty: recipe.difficulty,
            ingredients: ingredients,
            steps: nodes,
            stepEdges: edgeRecords
        )
        firebaseDatabase.updateRecipe(recipe: recipeRecord)
        let image = self.fetchRecipeImage(name: recipe.name)

        // TODO image??
        guard let fetchedImage = image, let onlineId = recipe.onlineId else {
            return
        }
        firebaseStorage.uploadImage(image: fetchedImage, name: onlineId)
    }

    // rate a recipe
    func rateRecipe(recipeId: String, userId: String, rating: RatingScore, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.addUserRecipeRating(userId: userId, rating: UserRating(recipeOnlineId: recipeId, score: rating))
        firebaseDatabase.addRecipeRating(onlineRecipeId: recipeId, rating: RecipeRating(userId: userId, score: rating), completion: completion)
    }

    // change the rating of a recipe you have rated before
    func rerateRecipe(recipeId: String, oldRating: RecipeRating, newRating: RecipeRating, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.updateRecipeRating(recipeId: recipeId, oldRating: oldRating, newRating: newRating, completion: completion)
        firebaseDatabase.updateUserRating(userId: newRating.userId,
                                          oldRating: UserRating(recipeOnlineId: recipeId, score: oldRating.score),
                                          newRating: UserRating(recipeOnlineId: recipeId, score: newRating.score))
    }

    // this should only be called once when the app first launched
    func createUser(user: UserRecord) throws -> String {
        try firebaseDatabase.addUser(user: user)
    }

    // follow someone
    func addFollowee(userId: String, followeeId: String, completion: @escaping (Error?) -> Void) {
        firebaseDatabase.addFollowee(userId: userId, followeeId: followeeId, completion: completion)
    }

    // MARK: - Storage Manager: Delete

    // unpublish a recipe through the online interface
    func removeOnlineRecipe(recipe: OnlineRecipe, completion: @escaping (Error?) -> Void) throws {
        try firebaseDatabase.removeRecipe(recipeId: recipe.id, completion: completion)
        for rating in recipe.ratings {
            firebaseDatabase.removeUserRecipeRating(
                userId: rating.userId,
                rating: UserRating(recipeOnlineId: recipe.id, score: rating.score)
            )
        }
        firebaseStorage.deleteImage(name: recipe.id)

        firebaseCache.onlineRecipeCache.removeValue(forKey: recipe.id)
        firebaseCache.imageCache.removeValue(forKey: recipe.id)

        // might alr have deleted local recipe
        let fetchedRecipe = try? self.fetchRecipeByOnlineId(onlineId: recipe.id)
        guard var localRecipe = fetchedRecipe else {
            return
        }
        localRecipe.onlineId = nil
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
            rating: UserRating(recipeOnlineId: recipeId, score: rating.score)
        )
    }

    // MARK: - Storage Manager: Fetch

    // fetch the details of a single recipe
    func fetchOnlineRecipe(id: String, completion: @escaping (OnlineRecipe?, Error?) -> Void) {
        firebaseDatabase.fetchOnlineRecipeInfo(id: id) { recipeInfo, err in
            guard let recipeInfo = recipeInfo else {
                completion(nil, err)
                return
            }

            firebaseDatabase.fetchOnlineRecipe(id: id) { onlineRecipeRecord, err in
                guard let recipeRecord = onlineRecipeRecord, let onlineRecipe = try? OnlineRecipe(from: recipeRecord, info: recipeInfo) else {
                    completion(nil, err)
                    return
                }
                completion(onlineRecipe, nil)
            }

        }
    }

    // fetch the details of a single user
    func fetchUserInfoById(userId: String, completion: @escaping (UserInfoRecord?, Error?) -> Void) {
        firebaseDatabase.fetchUserInfoById(userId: userId, completion: completion)
    }

    // fetch all recipes published by everyone
    func fetchAllOnlineRecipes(completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        firebaseDatabase.fetchAllRecipes(completion: completion)
    }

    // Fetch details of all users in the system
    func fetchAllUserInfos(completion: @escaping ([UserInfoRecord], Error?) -> Void) {
        firebaseDatabase.fetchAllUserInfos(completion: completion)
    }

    // Can be used to fetch all your own recipes or recipes of several selected users
    func fetchRecipesByUsers(userIds: [String], completion: @escaping ([OnlineRecipe], Error?) -> Void) {
        firebaseDatabase.fetchRecipeInfosByUsers(userIds: userIds) { recipeInfoRecords, err in
            if let err = err {
                completion([], err)
                return
            }

            // figure out which recipes actually need to fetch
            let recipesToFetch = recipeInfoRecords.values.filter{ recipeInfo in
                guard let id = recipeInfo.id, let updatedAt = recipeInfo.updatedAt else {
                    return false
                }
                return firebaseCache.onlineRecipeCache.isEntityCachedAndValid(id: id, updatedDate: updatedAt)
            }

            let recipeIdsToFetch = recipesToFetch.compactMap{$0.id}

            firebaseDatabase.fetchOnlineRecipes(ids: recipeIdsToFetch) { onlineRecipeRecords, _ in
                for onlineRecipeRecord in onlineRecipeRecords {
                    guard let id = onlineRecipeRecord.id else {
                        assertionFailure("Should have an id")
                        continue
                    }
                    guard let recipeInfoRecord = recipeInfoRecords[id], let onlineRecipe = try? OnlineRecipe(from: onlineRecipeRecord, info: recipeInfoRecord) else {
                        assertionFailure("Should have an id")
                        continue
                    }
                    firebaseCache.onlineRecipeCache.insert(onlineRecipe, forKey: id)
                }

                let recipes = recipeInfoRecords.keys.compactMap { firebaseCache.onlineRecipeCache[$0]
                }
                completion(recipes, nil)

            }

        }

//
//        recipeInfoRecords.forEach { allRecipeInfoRecords.dictionary[$0.id] = $0 }
//
//        for recipeInfoRecord in recipeInfoRecords {
//            guard let recipeInfoId = recipeInfoRecord.id else {
//                assertionFailure("Should have an id")
//                continue
//            }
//            if shouldFetchOnlineRecipe(recipeInfoRecord: recipeInfoRecord) {
//                recipeIdsToFetch.append(recipeInfoId)
//            }
//        }
//
//        guard !recipeIdsToFetch.isEmpty else {
//            let recipes = allRecipeInfoRecords.dictionary.compactMap { cache.onlineRecipeCache[$0.value.id ?? ""] }
//            completion(recipes, nil)
//            return
//        }
//
//        // to update cache with fetched recipes
//        let totalRecipeCount = recipeIdsToFetch.count
//        let queryLimit = QueryLimiter(max: totalRecipeCount)
//        while queryLimit.hasNext {
//            let range = [] + recipeIdsToFetch[queryLimit.current..<queryLimit.next()]
//            db.collection(recipePath).whereField(FieldPath.documentID(), in: range).getDocuments { snapshot, err in
//                guard let documents = snapshot?.documents else {
//                    completion([], err)
//                    assertionFailure("Should get some documents")
//                    return
//                }
//
//                for document in documents {
//                    guard let recipeRecord = try? document.data(as: OnlineRecipeRecord.self),
//                          let recipeInfoRecord = allRecipeInfoRecords.dictionary[recipeRecord.id],
//                          let recipe = try? OnlineRecipe(from: recipeRecord, info: recipeInfoRecord)
//                          else {
//                        completion([], err)
//                        continue
//                    }
//                    cache.onlineRecipeCache.insert(recipe, forKey: recipe.id)
//                    print(recipe.name)
//                }
//
//                let recipes = allRecipeInfoRecords.dictionary.compactMap { cache.onlineRecipeCache[$0.value.id ?? ""] }
//                completion(recipes, nil)
//            }
//        }
    }

    // download an online recipe to local
    func downloadRecipe(newName: String, recipe: OnlineRecipe) throws {
        var cuisineId: Int64?
        if let cuisine = recipe.cuisine {
            cuisineId = try self.fetchRecipeCategoryByName(name: cuisine)?.id
        }

        // must be both original owner and not have any local recipes currently connected to this online recipe
        // in order to establish a connection to this online recipe after download
        let isRecipeOwner = recipe.userId == UserDefaults.standard.string(forKey: "userId")
        let isRecipeAlreadyConnected = (try? fetchRecipeByOnlineId(onlineId: recipe.id)) == nil
        let newOnlineId = (isRecipeOwner && !isRecipeAlreadyConnected) ? recipe.id : nil

        var localRecipe = try Recipe(
            name: newName,
            onlineId: newOnlineId,
            servings: recipe.servings,
            recipeCategoryId: cuisineId,
            difficulty: recipe.difficulty,
            ingredients: recipe.ingredients,
            graph: recipe.stepGraph
        )
        try self.saveRecipe(&localRecipe)
        firebaseStorage.fetchImage(name: recipe.id) { data in
            let image = UIImage(data: data)
            guard let fetchedImage = image else {
                return
            }
            try? self.saveRecipeImage(fetchedImage, name: newName)
        }
    }

    func fetchOnlineRecipeImage(recipeId: String, completion: @escaping (Data) -> Void) {
        firebaseStorage.fetchImage(name: recipeId, completion: completion)
    }

    // MARK: - Storage Manager: Listen

    // listen to the details of a single user
    // use case: own user object
    func listenUserById(userId: String, onChange: @escaping (User) -> Void) {
        firebaseDatabase.listenUserById(userId: userId, onChange: onChange)
    }
}

enum StorageError: Error {
    case saveImageFailure
}
