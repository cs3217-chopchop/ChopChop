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
            accountSection
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
        .sheet(isPresented: $viewModel.sheetIsPresented, onDismiss: viewModel.addCategory) {
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

    @ViewBuilder
    var addRecipeCategorySheet: some View {
        VStack(alignment: .leading) {
            Text("Add Recipe Category")
                .font(.largeTitle)
                .bold()
                .padding(EdgeInsets(top: 32, leading: 16, bottom: 0, trailing: 16))
            Form {
                Section(header: Text("Recipe Category")) {
                    TextField("Name", text: $viewModel.categoryName)
                }
                Section {
                    Button("Done", action: {
                        viewModel.sheetIsPresented = false
                    })
                }
            }
        }
    }

    var addIngredientCategorySheet: some View {
        VStack(alignment: .leading) {
            Text("Add Ingredient Category")
                .font(.largeTitle)
                .bold()
                .padding(EdgeInsets(top: 32, leading: 16, bottom: 0, trailing: 16))
            Form {
                Section(header: Text("Ingredient Category")) {
                    TextField("Name", text: $viewModel.categoryName)
                }
                Section {
                    Button("Done", action: {
                        viewModel.sheetIsPresented = false
                    })
                }
            }
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

    var recipeFeedSection: some View {
        Section(header: Text("Recipe Feed")) {
            NavigationLink(
                destination: OnlineRecipeCollectionView(
                    viewModel: OnlineRecipeCollectionViewModel(publisher: viewModel.followeesRecipePublisher)) {
                    EmptyView()
                }
                    .navigationTitle("Recipes by Followees")
            ) {
                Label("Recipes by Followees", systemImage: "tray.2")
            }

            NavigationLink(
                destination: OnlineRecipeCollectionView(
                    viewModel: OnlineRecipeCollectionViewModel(publisher: viewModel.allRecipePublisher)) {
                    EmptyView()
                }
                    .navigationTitle("Discover")
            ) {
                Label("Discover", systemImage: "magnifyingglass")
            }
        }
    }

    var accountSection: some View {
        Section(header: Text("Account")) {
            NavigationLink(
                destination: ownProfileView
            ) {
                Label("Profile", systemImage: "person")
            }

            NavigationLink(
                destination: UserCollectionView(viewModel: UserCollectionViewModel(settings: settings))
            ) {
                Label("Followees", systemImage: "person.2")
            }

            NavigationLink(
                destination: NotFoundView(entityName: "User")
            ) {
                Label("Settings", systemImage: "gear")
            }
        }
    }

    @ViewBuilder
    var ownProfileView: some View {
        if let userId = settings.userId {
            ProfileView(viewModel: ProfileViewModel(userId: userId))
        } else {
            NotFoundView(entityName: "User")
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
