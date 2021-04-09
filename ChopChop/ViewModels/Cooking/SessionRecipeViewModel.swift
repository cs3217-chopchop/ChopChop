import SwiftUI

class SessionRecipeViewModel: ObservableObject {
    @Published var name: String
    @Published var servings: Double
    @Published var difficulty: Difficulty?
    @Published var ingredients: [RecipeIngredient]
    @Published var stepGraph: SessionRecipeStepGraph
    @Published var totalTimeTaken: String
    @Published var recipeCategory: String
    let sessionRecipe: SessionRecipe
    @Published var isShowComplete = false {
        didSet {
            if !isShowComplete && completeSessionRecipeViewModel.isSuccess {
                sessionRecipe.updateCompleted()
            }
        }
    }
    let completeSessionRecipeViewModel: CompleteSessionRecipeViewModel
    @Published var image: UIImage

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
        stepGraph = SessionRecipeStepGraph(graph: recipe.stepGraph) ?? SessionRecipeStepGraph()
        completeSessionRecipeViewModel = CompleteSessionRecipeViewModel(recipe: sessionRecipe.recipe)
        image = storageManager.fetchIngredientImage(name: recipe.name) ?? UIImage(imageLiteralResourceName: "recipe")
        self.recipeCategory = recipe.category?.name ?? ""
    }

    func toggleShowComplete() {
        isShowComplete.toggle()
    }

}
