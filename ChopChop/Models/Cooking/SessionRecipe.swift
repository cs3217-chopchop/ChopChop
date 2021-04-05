import Foundation

class SessionRecipe {
    private(set) var recipe: Recipe
    private(set) var stepGraph: SessionRecipeStepGraph
    private(set) var isCompleted = false

    init(recipe: Recipe) {
        self.recipe = recipe
        stepGraph = SessionRecipeStepGraph(graph: recipe.stepGraph) ?? SessionRecipeStepGraph()
    }

    func updateCompleted() {
        isCompleted = true
    }
}
