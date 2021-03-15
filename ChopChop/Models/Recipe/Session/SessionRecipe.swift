import Foundation

/// Conforms to ActionTimeTracker so that SessionRecipeStep can modify only 1 attribute through the delegate
class SessionRecipe: ActionTimeTracker {
    private(set) var timeOfLastAction = Date()
    private(set) var recipe: Recipe
    private(set) var sessionSteps: [SessionRecipeStep]! // implicitly unwrapped optional due to need to bind to self

    init(recipe: Recipe) {
        // A copy of the recipe object is made so that recipe on recipe tab dosen't actually get modified
        guard let recipeCopy = recipe.copy() as? Recipe else {
            fatalError()
        }
        self.recipe = recipeCopy
        sessionSteps = recipeCopy.steps.map{SessionRecipeStep(step: $0, actionTimeTracker: self)}
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

    /// Add/delete/reorder ingredients
    func updateIngredients(ingredients: [RecipeIngredient]) throws {
        try recipe.updateIngredients(ingredients: ingredients)
    }

    func updateServings(servings: Double) throws {
        try recipe.updateServings(servings: servings)
    }

    func updateTimeOfLastAction(date: Date) {
        timeOfLastAction = date
    }

}
