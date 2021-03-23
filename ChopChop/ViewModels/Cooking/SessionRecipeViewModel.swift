import SwiftUI

class SessionRecipeViewModel: ObservableObject {
    @Published var name: String
    @Published var servings: Double
    @Published var difficulty: Difficulty?
    @Published var ingredients: [RecipeIngredient]
    @Published var steps: [SessionRecipeStepViewModel]
    @Published var totalTimeTaken: String
    @Published var recipeCategory: String
    let sessionRecipe: SessionRecipe
    @Published var isShowComplete = false {
        didSet {
            if !isShowComplete && completeSessionRecipeViewModel.isSuccess {
                steps.forEach { $0.isDisabled = true }
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
        steps = sessionRecipe.sessionSteps.map { SessionRecipeStepViewModel(sessionRecipeStep: $0) }
        completeSessionRecipeViewModel = CompleteSessionRecipeViewModel(recipe: sessionRecipe.recipe)
        image = storageManager.fetchIngredientImage(name: recipe.name) ?? UIImage(imageLiteralResourceName: "recipe")

        guard let categoryId = recipe.recipeCategoryId,
              let recipeCategory = try? storageManager.fetchRecipeCategory(id: categoryId)?.name else {
            self.recipeCategory = ""
            return
        }
        self.recipeCategory = recipeCategory
    }

    func toggleShowComplete() {
        isShowComplete.toggle()
    }

}