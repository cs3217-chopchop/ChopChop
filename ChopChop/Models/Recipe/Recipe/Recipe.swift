import Foundation

/// Note there is no relationship between steps and ingredients after parsing stage
class Recipe {
    let id: Int64
    private(set) var name: String
    private(set) var servings: Double
    let cuisine: RecipeCategory
    private(set) var difficulty: Difficulty?
    private(set) var steps: [RecipeStep]
    private(set) var ingredients: [RecipeIngredient]

    init(id: Int64, name: String, servings: Double, cuisine: RecipeCategory, difficulty: Difficulty?, steps: [RecipeStep], ingredients: [RecipeIngredient]) {
        self.id = id
        self.name = name
        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.steps = steps
        self.ingredients = ingredients
        assert(checkRepresentation())
    }

    func updateName(name: String) throws {
        assert(checkRepresentation())
        guard name != "" else {
            throw RecipeError.invalidName
            // maybe just have a snackbar to display all errors
            // not sure how we r gonna display below the specific fields
        }
        self.name = name
        assert(checkRepresentation())
    }

    /// Update servings of recipe. Scales the ingredient quantities and updates steps with scaled quantities.
    /// Does not scale time taken and difficulty level
    /// - Parameter servings: <#servings description#>
    /// - Throws:
    ///     - `RecipeError.invalidServings`: if the given servings is less than 0.
    func updateServings(servings: Double) throws {
        assert(checkRepresentation())
        guard servings > 0 else {
            throw RecipeError.invalidServings
        }
        let scale = servings / self.servings
        self.servings = servings

        for ingredient in ingredients {
            ingredient.scaleQuantityMagnitude(scale: scale)
        }

        for step in steps {
            let updatedStep = RecipeStepParser.scaleNumerals(step: step.content, scale: scale)
            try step.updateContent(content: updatedStep)
        }
        assert(checkRepresentation())
    }

    func updateDifficulty(difficulty: Difficulty) {
        assert(checkRepresentation())
        self.difficulty = difficulty
        assert(checkRepresentation())
    }

    // use case: add/delete/reorder steps
    func updateSteps(steps: [RecipeStep]) {
        assert(checkRepresentation())
        self.steps = steps
        assert(checkRepresentation())
    }

    // use case: add/delete/reorder ingredients
    func updateIngredients(ingredients: [RecipeIngredient]) throws {
        assert(checkRepresentation())
        guard checkNoDuplicateIngredients(ingredients: ingredients) else {
            throw RecipeError.invalidIngredients
        }
        self.ingredients = ingredients
        assert(checkRepresentation())
    }

    /// Returns total time taken to complete the recipe in seconds, computed from time taken for each step
    var totalTimeTaken: Int {
        return steps.map({$0.timeTaken}).reduce(0, +)
    }

    private func checkRepresentation() -> Bool {
        name != "" && servings > 0 && !steps.isEmpty && !ingredients.isEmpty && checkNoDuplicateIngredients(ingredients: ingredients)
    }

    private func checkNoDuplicateIngredients(ingredients: [RecipeIngredient]) -> Bool {
        // synonyms of ingredients are allowed e.g. brinjal and eggplant
        return ingredients.allSatisfy{(ingredient) -> Bool in (ingredients.filter{$0.name == ingredient.name}.count == 1)}
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

        var newIngredients: [RecipeIngredient] = []
        for ingredient in ingredients {
            guard let recipeIngredient = ingredient.copy() as? RecipeIngredient else {
                fatalError()
            }
            newIngredients.append(recipeIngredient)
        }

        let copy = Recipe(id: id, name: name, servings: servings, cuisine: cuisine, difficulty: difficulty, steps: newSteps, ingredients: newIngredients)
        return copy
    }
}
