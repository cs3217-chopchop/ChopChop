import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Sidebar(recipeCategories: $viewModel.recipeCategories, ingredientCategories: $viewModel.ingredientCategories)

        RecipeCollectionView(viewModel: RecipeCollectionViewModel(category: RecipeCategory(name: "All Recipes")))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
