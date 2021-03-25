import Foundation
import GRDB

/// Note there is no relationship between steps and ingredients after parsing stage
class Recipe: FetchableRecord, ObservableObject {
    var id: Int64?
    @Published private(set) var name: String
    @Published private(set) var servings: Double
    @Published var recipeCategoryId: Int64?
    @Published private(set) var difficulty: Difficulty?
    @Published private(set) var steps: [RecipeStep]
    @Published private(set) var ingredients: [RecipeIngredient]

    init(name: String, servings: Double = 1, difficulty: Difficulty? = nil,
         steps: [RecipeStep] = [], ingredients: [RecipeIngredient] = []) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }
        self.name = trimmedName

        guard servings > 0 else {
            throw RecipeError.invalidServings
        }
        self.servings = servings
        self.difficulty = difficulty
        self.steps = steps
        self.ingredients = ingredients
        assert(checkRepresentation())
    }

    func updateRecipe(_ newRecipe: Recipe) {
        assert(checkRepresentation())
        name = newRecipe.name
        servings = newRecipe.servings
        recipeCategoryId = newRecipe.recipeCategoryId
        difficulty = newRecipe.difficulty
        steps = newRecipe.steps
        ingredients = newRecipe.ingredients
        assert(checkRepresentation())
    }

    // step related functions
    func addStep(content: String) throws {
        assert(checkRepresentation())
        steps.append(try RecipeStep(content: content))
        assert(checkRepresentation())
    }

    func removeStep(_ removedStep: RecipeStep) {
        assert(checkRepresentation())
        guard (steps.contains { $0 == removedStep }) else {
            return
        }

        steps.removeAll { $0 == removedStep }
        assert(checkRepresentation())
    }

    func reorderStep(idx1: Int, idx2: Int) throws {
        assert(checkRepresentation())
        guard idx1 >= 0 && idx1 < steps.count && idx2 >= 0 && idx2 < steps.count else {
            throw RecipeError.invalidReorderSteps
        }

        guard idx1 != idx2 else {
            return
        }

        let temp = steps[idx1]
        steps[idx1] = steps[idx2]
        steps[idx2] = temp
        assert(checkRepresentation())
    }

    // ingredient related functions
    func addIngredient(name: String, quantity: Quantity) throws {
        assert(checkRepresentation())
        if let existingIngredient = ingredients.first(where: { $0.name == name }) {
            try existingIngredient.add(quantity)
        } else {
            let addedIngredient = try RecipeIngredient(name: name, quantity: quantity)
            ingredients.append(addedIngredient)
        }
        assert(checkRepresentation())
    }

    func removeIngredient(_ removedIngredient: RecipeIngredient) throws {
        assert(checkRepresentation())
        guard (ingredients.contains { $0 == removedIngredient }) else {
            throw RecipeError.nonExistentIngredient
        }

        ingredients.removeAll { $0 == removedIngredient }
        assert(checkRepresentation())
    }

    func updateIngredient(oldIngredient: RecipeIngredient, name: String, quantity: Quantity) throws {
        // note there is no effect on steps on updating ingredients
        assert(checkRepresentation())
        guard ingredients.contains(where: { $0.name == oldIngredient.name }) else {
            throw RecipeError.nonExistentIngredient
        }
        if oldIngredient.name == name {
            oldIngredient.updateQuantity(quantity)
        } else {
            guard let existingIngredient = ingredients.first(where: { $0.name == name }) else {
                try oldIngredient.rename(name)
                oldIngredient.updateQuantity(quantity)
                return
            }
            try removeIngredient(oldIngredient)
            try existingIngredient.add(quantity)

        }
        assert(checkRepresentation())
    }

    /// Returns total time taken to complete the recipe in seconds, computed from time taken for each step
    var totalTimeTaken: Int {
        steps.map({ $0.timeTaken }).reduce(0, +)
    }

    private func checkRepresentation() -> Bool {
        !name.isEmpty && servings > 0 && checkNoDuplicateIngredients(ingredients: ingredients)
    }

    private func checkNoDuplicateIngredients(ingredients: [RecipeIngredient]) -> Bool {
        // synonyms of ingredients are allowed e.g. brinjal and eggplant
        return ingredients.allSatisfy { ingredient -> Bool in
            ingredients.filter { $0.name == ingredient.name }.count == 1
        }
    }

    required init(row: Row) {
        id = row[RecipeRecord.Columns.id]
        recipeCategoryId = row[RecipeRecord.Columns.recipeCategoryId]
        name = row[RecipeRecord.Columns.name]
        servings = row[RecipeRecord.Columns.servings]
        difficulty = row[RecipeRecord.Columns.difficulty]
        steps = row.prefetchedRows["recipeSteps"]?.compactMap {
            try? RecipeStep(content: RecipeStepRecord(row: $0).content)
        } ?? []
        ingredients = row.prefetchedRows["recipeIngredients"]?.compactMap {
            let record = RecipeIngredientRecord(row: $0)
            guard let quantity = try? Quantity(from: record.quantity) else {
                return nil
            }

            return try? RecipeIngredient(name: record.name, quantity: quantity)
        } ?? []
    }

}

extension Recipe: Equatable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.name == rhs.name
    }
}

extension Recipe: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newSteps = steps.compactMap { $0.copy() as? RecipeStep }
        let newIngredients = ingredients.compactMap { $0.copy() as? RecipeIngredient }

        do {
            let copy = try Recipe(
                name: name,
                servings: servings,
                difficulty: difficulty,
                steps: newSteps,
                ingredients: newIngredients)
            copy.id = id
            copy.recipeCategoryId = recipeCategoryId
            return copy
        } catch {
            fatalError("Cannot copy Recipe")
        }

    }
}

enum RecipeError: String, Error {
    case invalidName = "Recipe name cannot be empty."
    case invalidServings = "Recipe serving should be positive."
    case invalidCuisine = "Cuisine chosen is non-existent."
    case invalidIngredients = "Ingredients are invalid."
    case nonExistentStep = "Recipe step is non-existent."
    case nonExistentIngredient = "Ingredients are non-existent."
    case invalidReorderSteps = "Invalid reorder steps."
}
