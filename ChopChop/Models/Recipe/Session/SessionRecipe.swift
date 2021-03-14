import Foundation

class SessionRecipe: ActionTimeTracker {
    var timeOfLastAction = Date() // https://developer.apple.com/documentation/foundation/date

    var recipe: Recipe
    var sessionSteps: [SessionRecipeStep]! // implicitly unwrapped optional due to need to bind to self

    init(recipe: Recipe) {
        guard let recipe = recipe.copy() as? Recipe else {
            fatalError()
        } // so that recipe on recipe tab dosent actually get modified
        self.recipe = recipe
        sessionSteps = recipe.steps.map{SessionRecipeStep(step: $0, actionTimeTracker: self)}
    }

    // future use case: on complete, send session steps to user log
    var isCompleted: Bool {
        sessionSteps.allSatisfy{$0.isCompleted}
    }

    func updateName(name: String) throws {
        try recipe.updateName(name: name)
    }

    func updateDifficulty(difficulty: Difficulty) {
        recipe.updateDifficulty(difficulty: difficulty)
    }

    // add/delete/reorder ingredients
    func updateIngredients(ingredients: [RecipeIngredient]) throws {
        try recipe.updateIngredients(ingredients: ingredients)
    }

    // dont allow updates to servings
    // updates to steps done through SessionRecipeStep



}
