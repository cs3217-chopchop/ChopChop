import Foundation
import SwiftUI

 struct Sidebar: View {
    @Binding var recipeCategories: [RecipeCategory]
    @Binding var ingredientCategories: [IngredientCategory]

    var body: some View {
        List {
            Section(header: Text("Recipes")) {
                NavigationLink(
                    destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(category: RecipeCategory(name: "All Recipes")))
                ) {
                    Image(systemName: "tray.2")
                    Text("All Recipes")
                }
                ForEach(recipeCategories) { category in
                    NavigationLink(
                        destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(category: category))
                    ) {
                        Image(systemName: "folder")
                        Text(category.name)
                    }
                }
                NavigationLink(
                    destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(category:
                                                                                            RecipeCategory(id: 0, name: "Uncategorised")))
                ) {
                    Image(systemName: "questionmark.folder")
                    Text("Uncategorised")
                }
            }

            Section(header: Text("Ingredients")) {
                NavigationLink(
                    destination: Text("All Ingredients")
                ) {
                    Image(systemName: "tray.2")
                    Text("All Ingredients")
                }
                ForEach(ingredientCategories) { category in
                    NavigationLink(
                        destination: Text(category.name)
                    ) {
                        Image(systemName: "folder")
                        Text(category.name)
                    }
                }
                NavigationLink(
                    destination: Text("Uncategorised")
                ) {
                    Image(systemName: "questionmark.folder")
                    Text("Uncategorised")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(Text("ChopChop"))
    }
 }

// struct Sidebar_Previews: PreviewProvider {
//    static var previews: some View {
//        Sidebar(viewModel: SidebarViewModel(),
//                selectedCategory: .constant(nil),
//                selectedRecipe: .constant(nil))
//    }
// }
