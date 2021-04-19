import Foundation
import GRDB

/**
 Represents a recipe.
 
 Representation Invariants:
 - Name is not empty.
 - Servings is a positive number.
 - Ingredients do not contain duplicates, identified by name.
 - Step graph is valid.
 */
struct Recipe: Equatable {
    // MARK: - Specification Fields
    /// Identifies the row in the recipe table in the local storage that this recipe represents.
    var id: Int64?
    /// Identifies the document in the recipe collection in the cloud storage that this recipe represents.
    /// Is `nil` if the recipe is not published onto cloud storage.
    var onlineId: String?
    /// A flag representing whether an image for this recipe has been uploaded.
    var isImageUploaded: Bool
    /// Identifies the document in the recipe collection in the cloud storage that this recipe was downloaded from.
    /// Is `nil` if the recipe was not downloaded from an online recipe.
    var parentOnlineRecipeId: String?
    /// The name of the recipe. Cannot be empty.
    let name: String
    /// The category which the recipe belongs to.
    /// Is `nil` if the recipe does not belong to any category.
    let category: RecipeCategory?
    /// The number of people this recipe is designed to feed.
    let servings: Double
    /// A measure of the difficulty to make the recipe.
    /// Is `nil` if there is no associated difficulty.
    let difficulty: Difficulty?
    /// The ingredients required to make the recipe.
    let ingredients: [RecipeIngredient]
    /// The instructions to make the recipe, modeled as a graph.
    let stepGraph: RecipeStepGraph

    var totalTimeTaken: TimeInterval {
        stepGraph.nodes.map { $0.label.timeTaken }.reduce(0, +)
    }

    /**
     Instantiates a recipe with the given parameters.

     - Throws:
        - `RecipeError.invalidName` if the given name trimmed is empty.
        - `RecipeError.invalidServings` if the given serving size is non positive.
        - `RecipeError.duplicateIngredients` if the given ingredients contain duplicates.
     */
    init(id: Int64? = nil, onlineId: String? = nil, isImageUploaded: Bool = false, parentOnlineRecipeId: String? = nil,
         name: String, category: RecipeCategory? = nil, servings: Double = 1,
         difficulty: Difficulty? = nil, ingredients: [RecipeIngredient] = [],
         stepGraph: RecipeStepGraph = RecipeStepGraph()) throws {

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }

        guard servings > 0 else {
            throw RecipeError.invalidServings
        }

        guard ingredients.count == Set(ingredients.map { $0.name }).count else {
            throw RecipeError.duplicateIngredients
        }

        self.id = id
        self.onlineId = onlineId
        self.isImageUploaded = isImageUploaded
        self.parentOnlineRecipeId = parentOnlineRecipeId
        self.name = trimmedName
        self.category = category
        self.servings = servings
        self.difficulty = difficulty
        self.ingredients = ingredients
        self.stepGraph = stepGraph
    }
}

extension Recipe: FetchableRecord {
    init(row: Row) {
        id = row[RecipeRecord.Columns.id]
        onlineId = row[RecipeRecord.Columns.onlineId]
        isImageUploaded = row[RecipeRecord.Columns.isImageUploaded]
        parentOnlineRecipeId = row[RecipeRecord.Columns.parentOnlineRecipeId]
        category = row["recipeCategory"]
        name = row[RecipeRecord.Columns.name]
        servings = row[RecipeRecord.Columns.servings]
        difficulty = row[RecipeRecord.Columns.difficulty]
        ingredients = row.prefetchedRows["recipeIngredients"]?.compactMap {
            let record = RecipeIngredientRecord(row: $0)

            guard let quantity = try? Quantity(from: record.quantity) else {
                return nil
            }

            return try? RecipeIngredient(name: record.name, quantity: quantity)
        } ?? []

        stepGraph = row["recipeStepGraph"]
    }
}

enum RecipeError: LocalizedError {
    case invalidName, invalidServings, duplicateIngredients

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Recipe name should not be empty."
        case .invalidServings:
            return "Recipe serving size should be a positive number."
        case .duplicateIngredients:
            return "Recipe should not have duplicate ingredients."
        }
    }
}
