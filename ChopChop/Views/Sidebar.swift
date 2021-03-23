import SwiftUI

 struct Sidebar: View {
    @State var editMode = EditMode.inactive

    var recipeCategories: [RecipeCategory] = []
    var ingredientCategories: [IngredientCategory] = []
    let allRecipesViewModel: RecipeCollectionViewModel
    let cookingSelectionViewModel: CookingSelectionViewModel

    let deleteRecipeCategories: (IndexSet) -> Void
    let deleteIngredientCategories: (IndexSet) -> Void

    var body: some View {
        List {
            cookingSection
            recipesSection
            ingredientsSection
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            EditButton()
        }
        .navigationTitle(Text("ChopChop"))
        .environment(\.editMode, $editMode)
    }

    var cookingSection: some View {
        NavigationLink(
            destination: CookingSelectionView(viewModel: cookingSelectionViewModel)
        ) {
            Text("Cooking")
                .font(.title3)
                .bold()
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
                Label("All Recipes", systemImage: "tray.2")
            }

            ForEach(recipeCategories) { category in
                NavigationLink(
                    destination: RecipeCollectionView(viewModel:
                                                        RecipeCollectionViewModel(
                                                            title: category.name,
                                                            categoryIds: [category.id].compactMap { $0 }))
                ) {
                    Label {
                        Text(category.name)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "folder")
                    }
                }
            }
            .onDelete(perform: deleteRecipeCategories)
            .deleteDisabled(!editMode.isEditing)

            NavigationLink(
                destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: "Uncategorised"))
            ) {
                Label("Uncategorised", systemImage: "questionmark.folder")
            }

            if editMode.isEditing {
                Button(action: {
                    print("add")
                }) {
                    Label("Add a recipe category...", systemImage: "plus")
                }
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
                Label("All Ingredients", systemImage: "tray.2")
            }

            ForEach(ingredientCategories) { category in
                NavigationLink(
                    destination: IngredientCollectionView(viewModel:
                                                        IngredientCollectionViewModel(
                                                            title: category.name,
                                                            categoryIds: [category.id].compactMap { $0 }))
                ) {
                    Label {
                        Text(category.name)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "folder")
                    }

                }
            }
            .onDelete(perform: deleteIngredientCategories)
            .deleteDisabled(!editMode.isEditing)

            NavigationLink(
                destination: IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: "Uncategorised"))
            ) {
                Label("Uncategorised", systemImage: "questionmark.folder")
            }

            if editMode.isEditing {
                Button(action: {
                    print("add")
                }) {
                    Label("Add an ingredient category...", systemImage: "plus")
                }
            }
        }
    }
 }

 struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(allRecipesViewModel: RecipeCollectionViewModel(title: ""),
                cookingSelectionViewModel: CookingSelectionViewModel(categoryIds: []),
                deleteRecipeCategories: { _ in },
                deleteIngredientCategories: { _ in })
    }
 }
