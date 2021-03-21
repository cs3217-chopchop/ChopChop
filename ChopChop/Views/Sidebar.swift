import SwiftUI

 struct Sidebar: View {
    var recipeCategories: [RecipeCategory] = []
    var ingredientCategories: [IngredientCategory] = []

    var body: some View {
        List {
            RecipesSection()
            IngredientsSection()
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(Text("ChopChop"))
    }

    func RecipesSection() -> some View {
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

    func IngredientsSection() -> some View {
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
        Sidebar()
    }
 }
