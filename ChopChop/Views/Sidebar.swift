import SwiftUI

 struct Sidebar: View {
    @ObservedObject var viewModel: SidebarViewModel
    @Binding var editMode: EditMode
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        List {
            cookingSection
            recipesSection
            ingredientsSection
            recipeFeedSection
            usersSection
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            HStack(spacing: 16) {
                if editMode.isEditing {
                    Menu {
                        Button("Recipe Category", action: {
                            viewModel.sheetIsPresented = true
                            viewModel.categoryType = .recipe
                        })
                        Button("Ingredient Category", action: {
                            viewModel.sheetIsPresented = true
                            viewModel.categoryType = .ingredient
                        })
                    } label: {
                        Text("Add")
                    }
                }

                EditButton()
            }
        }
        .navigationTitle(Text("ChopChop"))
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .sheet(isPresented: $viewModel.sheetIsPresented, onDismiss: {
            switch viewModel.categoryType {
            case .recipe:
                viewModel.addRecipeCategory(name: viewModel.categoryName)
            case .ingredient:
                viewModel.addIngredientCategory(name: viewModel.categoryName)
            case .none:
                return
            }

            viewModel.categoryName = ""
            viewModel.categoryType = nil
        }) {
            switch viewModel.categoryType {
            case .recipe:
                addRecipeCategorySheet
            case .ingredient:
                addIngredientCategorySheet
            case .none:
                EmptyView()
            }
        }
        .environment(\.editMode, $editMode)
    }

    var addRecipeCategorySheet: some View {
        VStack {
            Text("Add Recipe Category")
                .font(.title)
            TextField("Category", text: $viewModel.categoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Done", action: {
                viewModel.sheetIsPresented = false
            })
        }
    }

    var addIngredientCategorySheet: some View {
        VStack {
            Text("Add Ingredient Category")
                .font(.title)
            TextField("Category", text: $viewModel.categoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Done", action: {
                viewModel.sheetIsPresented = false
            })
        }
    }

    var cookingSection: some View {
        NavigationLink(
            destination: CookingSelectionView(viewModel:
                                                CookingSelectionViewModel(categoryIds: viewModel.recipeCategories
                                                                            .compactMap { $0.id } + [nil]))
        ) {
            Text("Cooking")
                .font(.title3)
                .bold()
        }
    }

    var recipesSection: some View {
        Section(header: Text("Recipes")) {
            allRecipesTab

            ForEach(viewModel.recipeCategories) { category in
                recipeCategoryTab(category)
            }
            .onDelete(perform: viewModel.deleteRecipeCategories)
            .deleteDisabled(!editMode.isEditing)

            uncategorisedRecipesTab
        }
    }

    private var allRecipesTab: some View {
        NavigationLink(
            destination: RecipeCollectionView(
                viewModel: RecipeCollectionViewModel(
                    title: "All Recipes",
                    categoryIds: viewModel.recipeCategories.compactMap { $0.id } + [nil]))
        ) {
            Label("All Recipes", systemImage: "tray.2")
        }
    }

    private func recipeCategoryTab(_ category: RecipeCategory) -> some View {
        NavigationLink(
            destination: RecipeCollectionView(
                viewModel: RecipeCollectionViewModel(
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

    private var uncategorisedRecipesTab: some View {
        NavigationLink(
            destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: "Uncategorised"))
        ) {
            Label("Uncategorised", systemImage: "questionmark.folder")
        }
    }

    var ingredientsSection: some View {
        Section(header: Text("Ingredients")) {
            allIngredientsTab

            ForEach(viewModel.ingredientCategories) { category in
                ingredientCategoryTab(category)
            }
            .onDelete(perform: viewModel.deleteIngredientCategories)
            .deleteDisabled(!editMode.isEditing)

            uncategorisedIngredientsTab
        }
    }

    private var allIngredientsTab: some View {
        NavigationLink(
            destination: IngredientCollectionView(
                viewModel: IngredientCollectionViewModel(
                    title: "All Ingredients",
                    categoryIds: viewModel.ingredientCategories.compactMap { $0.id } + [nil]))
        ) {
            Label("All Ingredients", systemImage: "tray.2")
        }
    }

    private func ingredientCategoryTab(_ category: IngredientCategory) -> some View {
        NavigationLink(
            destination: IngredientCollectionView(
                viewModel: IngredientCollectionViewModel(
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

    var usersSection: some View {
        NavigationLink(
            destination: UserCollectionView(viewModel: UserCollectionViewModel(settings: settings))
        ) {
            Text("Users")
                .font(.title3)
                .bold()
        }
    }

    var recipeFeedSection: some View {
        Section(header: Text("Recipe Feed")) {
            NavigationLink(
                destination: OnlineRecipeCollectionView(viewModel:
                                OnlineRecipeCollectionViewModel(userIds: nil))
                    .navigationTitle("All Recipes")
            ) {
                Label("All Recipes", systemImage: "tray.2")
            }

            NavigationLink(
                destination: OnlineRecipeCollectionView(viewModel:
                                                            OnlineRecipeCollectionViewModel(userIds: settings.user?.followees))
                    .navigationTitle("Recipes from followees")
            ) {
                Label("Recipes from followees", systemImage: "folder")
            }

            NavigationLink(
                destination: OnlineRecipeCollectionView(viewModel:
                                OnlineRecipeCollectionViewModel(userIds: [settings.userId].compactMap { $0 }))
                    .navigationTitle("My Published Recipes")
            ) {
                Label("My Published Recipes", systemImage: "folder")
            }

        }
    }

    private var uncategorisedIngredientsTab: some View {
        NavigationLink(
            destination: IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: "Uncategorised"))
        ) {
            Label("Uncategorised", systemImage: "questionmark.folder")
        }
    }
 }

 struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(viewModel: SidebarViewModel(settings: UserSettings()), editMode: .constant(EditMode.inactive))
    }
 }
