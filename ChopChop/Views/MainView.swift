import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    let allRecipesViewModel: RecipeCollectionViewModel
    let cookingSelectionViewModel: CookingSelectionViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        allRecipesViewModel = RecipeCollectionViewModel(title: "All Recipes",
                                                        categoryIds: viewModel.recipeCategories
                                                          .compactMap { $0.id } + [nil])
        cookingSelectionViewModel = CookingSelectionViewModel(categoryIds: viewModel.recipeCategories
                                                                .compactMap { $0.id } + [nil])
    }

    var body: some View {
        Sidebar(recipeCategories: viewModel.recipeCategories,
                ingredientCategories: viewModel.ingredientCategories,
                allRecipesViewModel: allRecipesViewModel,
                cookingSelectionViewModel: cookingSelectionViewModel,
                deleteRecipeCategories: viewModel.deleteRecipeCategories,
                deleteIngredientCategories: viewModel.deleteIngredientCategories)

        RecipeCollectionView(viewModel: allRecipesViewModel)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
