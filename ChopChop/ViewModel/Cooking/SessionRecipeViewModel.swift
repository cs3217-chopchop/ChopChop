import SwiftUI

class SessionRecipeViewModel: ObservableObject {
    @Published var name: String
    @Published var servings: Double
    @Published var difficulty: Int
    @Published var ingredients: [RecipeIngredient]
    @Published var steps: [SessionRecipeStep]
    let sessionRecipe: SessionRecipe
    @Published var isShowComplete = false
    let completeSessionRecipeViewModel: CompleteSessionRecipeViewModel

    init(sessionRecipe: SessionRecipe) {
        self.sessionRecipe = sessionRecipe
        name = sessionRecipe.recipe.name
        servings = sessionRecipe.recipe.servings
        difficulty = sessionRecipe.recipe.difficulty?.rawValue ?? 0
        ingredients = sessionRecipe.recipe.ingredients
        steps = sessionRecipe.sessionSteps
        completeSessionRecipeViewModel = CompleteSessionRecipeViewModel(recipe: sessionRecipe.recipe)
    }

    func toggleShowComplete() {
        isShowComplete.toggle()
    }

}
