struct SessionRecipe {
    let recipe: Recipe
    let stepGraph: SessionRecipeStepGraph

    init(recipe: Recipe) {
        self.recipe = recipe
        stepGraph = (try? SessionRecipeStepGraph(graph: recipe.stepGraph)) ?? SessionRecipeStepGraph()
    }
}
