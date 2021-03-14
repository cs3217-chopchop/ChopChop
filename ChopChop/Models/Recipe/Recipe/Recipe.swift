import Foundation

/// Note there is no relationship between steps and ingredients after parsing stage
class Recipe {
    let id: Int64
    var name: String
    var servings: Double
    let cuisine: String // string or enum?
    var difficulty: Difficulty?
    var steps: [RecipeStep]
    var ingredients: [RecipeIngredient]

    init(id: Int64, name: String, servings: Double, cuisine: String, difficulty: Difficulty?, steps: [RecipeStep], ingredients: [RecipeIngredient]) {
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

    func updateServings(servings: Double) throws {
        assert(checkRepresentation())
        guard servings > 0 else {
            throw RecipeError.invalidServings
        }
        let scale = servings / self.servings
        self.servings = servings

        // auto scale ingredients
        for ingredient in ingredients {
            ingredient.scaleQuantityMagnitude(scale: scale)
        }

        let parser = RecipeStepParser()
        for step in steps {
            let updatedStep = parser.scaleNumerals(step: step.content, scale: scale)
            step.updateContent(content: updatedStep)
        }
        assert(checkRepresentation())

        // assume difficulty does not scale by servings size
    }

    func updateDifficulty(difficulty: Difficulty) {
        assert(checkRepresentation())
        self.difficulty = difficulty
        assert(checkRepresentation())
    }

    // add/delete/reorder steps
    func updateSteps(steps: [RecipeStep]) {
        assert(checkRepresentation())
        self.steps = steps
        assert(checkRepresentation())
    }

    // add/delete/reorder ingredients
    func updateIngredients(ingredients: [RecipeIngredient]) throws {
        assert(checkRepresentation())
        guard checkNoDuplicateIngredients(ingredients: ingredients) else {
            throw RecipeError.invalidIngredients
        }
        self.ingredients = ingredients
        assert(checkRepresentation())
    }

    var totalTimeTaken: Double {
        return steps.map({$0.timeTaken}).reduce(0, +)
    }

    private func checkRepresentation() -> Bool {
        name != "" && servings > 0 && cuisine != "" && !steps.isEmpty && !ingredients.isEmpty && checkNoDuplicateIngredients(ingredients: ingredients)
        // no repeat of name ingredients (how to get rid of synonyms?)

    }

    private func checkNoDuplicateIngredients(ingredients: [RecipeIngredient]) -> Bool {
        // preferably have a list of synonyms ??
        return ingredients.allSatisfy{(ingredient) -> Bool in (ingredients.filter{$0.name == ingredient.name}.count == 1)}
    }

    // recipeManager to check recipe vs recipe problems
    // eg if there are duplicate names
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
