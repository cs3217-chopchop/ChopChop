import Foundation
import GRDB

/// Note there is no relationship between steps and ingredients after parsing stage
class Recipe: FetchableRecord {
    var id: Int64?
    private(set) var name: String
    private(set) var servings: Double
    var recipeCategoryId: Int64?
    private(set) var difficulty: Difficulty?
    private(set) var steps: [RecipeStep]
    private(set) var ingredients: [RecipeIngredient]

    init(name: String, servings: Double = 1, difficulty: Difficulty? = nil, steps: [RecipeStep] = [], ingredients: [RecipeIngredient] = []) throws {
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

    func updateName(_ name: String) throws {
        assert(checkRepresentation())
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }
        self.name = trimmedName
        assert(checkRepresentation())
    }

    func updateRecipeCategory(_ recipeCategory: Int64) {
        assert(checkRepresentation())
        self.recipeCategoryId = recipeCategory
        assert(checkRepresentation())
    }

    func updateDifficulty(_ difficulty: Difficulty) {
        assert(checkRepresentation())
        self.difficulty = difficulty
        assert(checkRepresentation())
    }

    // step related functions
    func addStep(_ addedStep: RecipeStep) {
        assert(checkRepresentation())
        steps.append(addedStep)
        assert(checkRepresentation())
    }

    func removeStep(_ removedStep: RecipeStep) throws {
        assert(checkRepresentation())
        guard (steps.contains { $0 === removedStep }) else {
            throw RecipeError.nonExistentStep
        }

        steps.removeAll { $0 === removedStep }
        assert(checkRepresentation())
    }

    // reorder step from larger to smaller index
    func moveStepUp(_ movedStep: RecipeStep) throws {
        assert(checkRepresentation())
        guard let idx = (steps.firstIndex { $0 === movedStep }) else {
            throw RecipeError.nonExistentStep
        }

        guard idx > 0 else {
            return
        }

        steps[idx] = steps[idx - 1]
        steps[idx - 1] = movedStep
        assert(checkRepresentation())
    }

    // reorder step from smaller to larger index
    func moveStepDown(_ movedStep: RecipeStep) throws {
        assert(checkRepresentation())
        guard let idx = (steps.firstIndex { $0 === movedStep }) else {
            throw RecipeError.nonExistentStep
        }

        guard idx < steps.count - 1 else {
            return
        }

        steps[idx] = steps[idx + 1]
        steps[idx + 1] = movedStep
        assert(checkRepresentation())
    }

    // ingredient related functions
    func addIngredient(_ addedIngredient: RecipeIngredient) throws {
        assert(checkRepresentation())
        guard checkNoDuplicateIngredients(ingredients: ingredients + [addedIngredient]) else {
            throw RecipeError.invalidIngredients
        }
        ingredients.append(addedIngredient)
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

    func updateIngredient(oldIngredient: RecipeIngredient, updatedIngredient: RecipeIngredient) throws {
        // note there is no effect on steps on updating ingredients
        assert(checkRepresentation())
        try removeIngredient(oldIngredient)
        try addIngredient(updatedIngredient)
        assert(checkRepresentation())
    }

    /// Returns total time taken to complete the recipe in seconds, computed from time taken for each step
    var totalTimeTaken: Int {
        steps.map({ $0.timeTaken }).reduce(0, +)
    }

    private func checkRepresentation() -> Bool {
        name != "" && servings > 0 && checkNoDuplicateIngredients(ingredients: ingredients)
    }

    private func checkNoDuplicateIngredients(ingredients: [RecipeIngredient]) -> Bool {
        // synonyms of ingredients are allowed e.g. brinjal and eggplant
        return ingredients.allSatisfy { ingredient -> Bool in
            ingredients.filter { $0.name == ingredient.name }.count == 1
        }
    }

    func canSave() -> Bool {
        checkRepresentation() && recipeCategoryId != nil && !steps.isEmpty && !ingredients.isEmpty
    }

    required init(row: Row) {
        id = row["id"]
        servings = row["servings"]
        recipeCategoryId = row["recipeCategoryId"]
        name = row["name"]
        difficulty = row["difficulty"]
        steps = row.prefetchedRows["recipeSteps"]?.map { RecipeStep(content: RecipeStepRecord(row: $0).content) } ?? []
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
        lhs.name == rhs.name && lhs.servings == rhs.servings && lhs.recipeCategoryId == rhs.recipeCategoryId && lhs.difficulty == rhs.difficulty
    }
}

extension Recipe: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        var newSteps: [RecipeStep] = []
        for step in steps {
            guard let recipeStep = step.copy() as? RecipeStep else {
                fatalError()
            }
            newSteps.append(recipeStep)
        }

        do {
            let copy = try Recipe(name: name, servings: servings, difficulty: difficulty, steps: newSteps, ingredients: ingredients)
            copy.id = id
            copy.recipeCategoryId = recipeCategoryId
            return copy
        } catch {
            fatalError()
        }

    }
}

enum RecipeError: Error {
    case invalidName
    case invalidServings
    case invalidCuisine
    case invalidIngredients
    case nonExistentStep
    case nonExistentIngredient
}
