import SwiftUI

 struct Sidebar: View {
    var recipeCategories: [RecipeCategory] = []
    var ingredientCategories: [IngredientCategory] = []
    let allRecipesViewModel: RecipeCollectionViewModel

    var body: some View {
        List {
            cookingSection
            recipesSection
            ingredientsSection
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(Text("ChopChop"))
    }

    var cookingSection: some View {
        NavigationLink(
            destination: CookingSelectionView(viewModel: RecipeCollectionViewModel(
                                                title: "All Recipes",
                                                categoryIds: recipeCategories.compactMap { $0.id } + [nil]))
        ) {
            Text("Cooking")
                .font(.title3)
                .bold()
//                .foregroundColor(.blue)
        }
    }

    var recipesSection: some View {
        Section(header: Text("Recipes")) {
            NavigationLink(
                destination: RecipeCollectionView(viewModel:
                                                    RecipeCollectionViewModel(
                                                        title: "All Recipes",
                                                        categoryIds: recipeCategories.compactMap { $0.id } + [nil]))
            ) {
                Image(systemName: "tray.2")
                Text("All Recipes")
            }
            ForEach(recipeCategories) { category in
                NavigationLink(
                    destination: RecipeCollectionView(viewModel:
                                                        RecipeCollectionViewModel(
                                                            title: category.name,
                                                            categoryIds: [category.id].compactMap { $0 }))
                ) {
                    Image(systemName: "folder")
                    Text(category.name)
                        .lineLimit(1)
                }
            }
            NavigationLink(
                destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: "Uncategorised"))
            ) {
                Image(systemName: "questionmark.folder")
                Text("Uncategorised")
            }
        }
    }

    var ingredientsSection: some View {
        Section(header: Text("Ingredients")) {
            NavigationLink(
                destination: IngredientCollectionView(viewModel:
                                                    IngredientCollectionViewModel(
                                                        title: "All Ingredients",
                                                        categoryIds: ingredientCategories.compactMap { $0.id } + [nil]))
            ) {
                Image(systemName: "tray.2")
                Text("All Ingredients")
            }
            ForEach(ingredientCategories) { category in
                NavigationLink(
                    destination: IngredientCollectionView(viewModel:
                                                        IngredientCollectionViewModel(
                                                            title: category.name,
                                                            categoryIds: [category.id].compactMap { $0 }))
                ) {
                    Image(systemName: "folder")
                    Text(category.name)
                        .lineLimit(1)
                }
            }
            NavigationLink(
                destination: IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: "Uncategorised"))
            ) {
                Image(systemName: "questionmark.folder")
                Text("Uncategorised")
            }
        }
    }
 }

 struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(allRecipesViewModel: RecipeCollectionViewModel(title: ""))
    }
 }
