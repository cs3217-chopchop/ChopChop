/**
 Represents a recipe that is being made.
 
 Representation Invariants:
 - Recipe is valid.
 - Step graph is valid.
 */
struct SessionRecipe {
    // MARK: - Specification Fields
    /// The recipe that is being made.
    let recipe: Recipe
    /// The instructions for the recipe that is being made, modeled as a graph.
    let stepGraph: SessionRecipeStepGraph

    /**
     Initialises a session recipe with the given recipe.
     */
    init(recipe: Recipe) {
        self.recipe = recipe
        stepGraph = (try? SessionRecipeStepGraph(graph: recipe.stepGraph)) ?? SessionRecipeStepGraph()
    }
}
