import SwiftUI

struct MainView: View {
    @State private var selectedCategory: RecipeCategory? = RecipeCategory(name: "All Recipes")
    @State private var selectedRecipe: RecipeInfo?

    var body: some View {
        Sidebar(viewModel: SidebarViewModel(),
                selectedCategory: $selectedCategory,
                selectedRecipe: $selectedRecipe)

        Text("Select category...")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
