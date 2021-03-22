import SwiftUI

class SessionRecipeViewModel: ObservableObject {
    @Published var name: String
    @Published var servings: Double
    @Published var difficulty: Difficulty?
    @Published var ingredients: [RecipeIngredient]
    @Published var steps: [SessionRecipeStep]
    @Published var totalTimeTaken: String
    let sessionRecipe: SessionRecipe
    @Published var isShowComplete = false
    let completeSessionRecipeViewModel: CompleteSessionRecipeViewModel
    private let storageManager = StorageManager()

    init(recipeInfo: RecipeInfo) {
        guard let id = recipeInfo.id, let recipe = try? storageManager.fetchRecipe(id: id) else {
            fatalError("Recipe does not exist")
        }
        name = recipe.name
        servings = recipe.servings
        difficulty = recipe.difficulty
        ingredients = recipe.ingredients
        totalTimeTaken = get_HHMMSS_Display(seconds: recipe.totalTimeTaken)
        sessionRecipe = SessionRecipe(recipe: recipe)
        steps = sessionRecipe.sessionSteps
        completeSessionRecipeViewModel = CompleteSessionRecipeViewModel(recipe: sessionRecipe.recipe)
    }

    func toggleShowComplete() {
        isShowComplete.toggle()
    }

}
