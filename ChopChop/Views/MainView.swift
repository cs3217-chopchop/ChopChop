import SwiftUI

struct MainView: View {
    @State private var selectedCategory: RecipeCategory?
    @State private var selectedRecipe: RecipeInfo?

    var body: some View {
        Sidebar(viewModel: SidebarViewModel(),
                selectedCategory: $selectedCategory,
                selectedRecipe: $selectedRecipe)

        RecipeCollectionView(viewModel: RecipeCollectionViewModel(selectedCategory: RecipeCategory(name: "All Recipes")),
                             selectedRecipe: $selectedRecipe)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
