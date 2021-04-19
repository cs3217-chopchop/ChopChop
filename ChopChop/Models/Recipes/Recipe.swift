import Foundation
import GRDB

struct Recipe: Equatable {
    var id: Int64?
    var onlineId: String?
    var isImageUploaded: Bool?
    var parentOnlineRecipeId: String?
    let name: String
    let category: RecipeCategory?
    let servings: Double
    let difficulty: Difficulty?
    let ingredients: [RecipeIngredient]
    let stepGraph: RecipeStepGraph

    var totalTimeTaken: TimeInterval {
        stepGraph.nodes.map { $0.label.timeTaken }.reduce(0, +)
    }

    // swiftlint:disable function_default_parameter_at_end
    init(id: Int64? = nil, onlineId: String? = nil, isImageUploaded: Bool? = nil, parentOnlineRecipeId: String? = nil,
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
    // swiftlint:enable function_default_parameter_at_end
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
