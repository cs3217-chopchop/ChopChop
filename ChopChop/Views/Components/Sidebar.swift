import Foundation
import SwiftUI

struct Sidebar: View {
    @ObservedObject var viewModel: SidebarViewModel
    @Binding var selectedCategory: RecipeCategory?
    @Binding var selectedRecipe: RecipeInfo?

    var body: some View {
        List {
            Section(header: Text("Recipes")) {
                ForEach(viewModel.recipeCategories) { category in
                    NavigationLink(
                        destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(selectedCategory: selectedCategory),
                                                          selectedRecipe: $selectedRecipe),
                        tag: category,
                        selection: $selectedCategory
                    ) {
                        Text(category.name)
                    }
                }
            }

            Section(header: Text("Ingredients")) {
                ForEach(viewModel.recipeCategories) { category in
                    NavigationLink(
                        destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(selectedCategory: selectedCategory),
                                                          selectedRecipe: $selectedRecipe),
                        tag: category,
                        selection: $selectedCategory
                    ) {
                        Text(category.name)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(Text("ChopChop"))
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(viewModel: SidebarViewModel(),
                selectedCategory: .constant(nil),
                selectedRecipe: .constant(nil))
    }
}
