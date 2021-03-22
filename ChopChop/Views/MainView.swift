import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    let allRecipesViewModel: RecipeCollectionViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        allRecipesViewModel = RecipeCollectionViewModel(title: "All Recipes",
                                                        categoryIds: viewModel.recipeCategories
                                                          .compactMap { $0.id } + [nil])
    }

    var body: some View {
        Sidebar(recipeCategories: viewModel.recipeCategories,
                ingredientCategories: viewModel.ingredientCategories,
                allRecipesViewModel: allRecipesViewModel)

        RecipeCollectionView(viewModel: allRecipesViewModel)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
