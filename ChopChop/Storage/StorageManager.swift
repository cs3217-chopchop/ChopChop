import Combine
import UIKit

struct StorageManager {
    let appDatabase: AppDatabase

    init(_ appDatabase: AppDatabase = .shared) {
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
                                                name: ingredient.name)
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

    // MARK: - Database Access: Publishers

    func recipesOrderedByNamePublisher() -> AnyPublisher<[RecipeInfo], Error> {
        appDatabase.recipesOrderedByNamePublisher()
            .map { $0.map { RecipeInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func recipesFilteredByCategoryOrderedByNamePublisher(ids: [Int64]) -> AnyPublisher<[RecipeInfo], Error> {
        appDatabase.recipesFilteredByCategoryOrderedByNamePublisher(ids: ids)
            .map { $0.map { RecipeInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func recipesFilteredByNamePublisher(_ query: String) -> AnyPublisher<[RecipeInfo], Error> {
        appDatabase.recipesFilteredByNamePublisher(query)
            .map { $0.map { RecipeInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func recipesFilteredByNameAndCategoryPublisher(query: String, categoryIds: [Int64]) -> AnyPublisher<[RecipeInfo], Error> {
        appDatabase.recipesFilteredByNameAndCategoryPublisher(query: query, categoryIds: categoryIds)
            .map { $0.map { RecipeInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func recipesFilteredByContentsPublisher(_ query: String) -> AnyPublisher<[RecipeInfo], Error> {
        appDatabase.recipesFilteredByContentsPublisher(query)
            .map { $0.map { RecipeInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func recipeCategoriesOrderedByNamePublisher() -> AnyPublisher<[RecipeCategory], Error> {
        appDatabase.recipeCategoriesOrderedByNamePublisher()
            .map { $0.compactMap { try? RecipeCategory(id: $0.id, name: $0.name ) } }
            .eraseToAnyPublisher()
    }

    func recipeIngredientsPublisher() -> AnyPublisher<[String: [Int64]], Error> {
        appDatabase.recipeIngredientsPublisher()
            .map { $0.reduce(into: [:]) { ingredients, ingredient in
                guard let id = ingredient.recipeId else {
                    return
                }

                ingredients[ingredient.name, default: []].append(id)
            }
            }
            .eraseToAnyPublisher()
    }

    func ingredientsOrderedByNamePublisher() -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsOrderedByNamePublisher()
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func ingredientsFilteredByCategoryOrderedByNamePublisher(ids: [Int64]) -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsFilteredByCategoryOrderedByNamePublisher(ids: ids)
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func ingredientsFilteredByNamePublisher(_ query: String) -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsFilteredByNamePublisher(query)
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func ingredientsOrderedByExpiryDatePublisher() -> AnyPublisher<[IngredientInfo], Error> {
        appDatabase.ingredientsOrderedByExpiryDatePublisher()
            .map { $0.map { IngredientInfo(id: $0.id, name: $0.name) } }
            .eraseToAnyPublisher()
    }

    func ingredientCategoriesOrderedByNamePublisher() -> AnyPublisher<[IngredientCategory], Error> {
        appDatabase.ingredientCategoriesOrderedByNamePublisher()
            .map { $0.compactMap { try? IngredientCategory(name: $0.name, id: $0.id) } }
            .eraseToAnyPublisher()
    }
}

// MARK: - Images Persistence
extension StorageManager {
    static let ingredientFolderName = "Ingredient"
    static let recipeFolderName = "Recipe"

    func deleteRecipeImage(name: String) {
        ImageStore.delete(imageNamed: name, inFolderNamed: StorageManager.recipeFolderName)
    }

    func renameRecipeImage(from oldName: String, to newName: String) throws {
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
        try ImageStore.save(image: image, name: name, inFolderNamed: StorageManager.ingredientFolderName)
    }
}
