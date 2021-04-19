import SwiftUI

/**
 Represents a view of the sidebar.
 */
 struct Sidebar: View {
    @ObservedObject var viewModel: SidebarViewModel
    @Binding var editMode: EditMode
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        List {
            recipesSection
            ingredientsSection
            recipeFeedSection
            accountSection
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            editToolbar
        }
        .navigationTitle(Text("ChopChop"))
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .sheet(isPresented: $viewModel.sheetIsPresented, onDismiss: viewModel.addCategory) {
            sheetView
        }
        .environment(\.editMode, $editMode)
    }

    // MARK: - Recipe Section

    private var recipesSection: some View {
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

    // MARK: - Ingredient Section

    private var ingredientsSection: some View {
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

    private var uncategorisedIngredientsTab: some View {
        NavigationLink(
            destination: IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: "Uncategorised"))
        ) {
            Label("Uncategorised", systemImage: "questionmark.folder")
        }
    }

    // MARK: - Recipe Feed Section

    private var recipeFeedSection: some View {
        Section(header: Text("Recipe Feed")) {
            followeeFeedLink
            discoverFeedLink
        }
    }

    private var followeeFeedLink: some View {
        NavigationLink(
            destination: OnlineRecipeCollectionView(
                viewModel: OnlineRecipeCollectionViewModel(filter: .followees, settings: settings)) {
                EmptyView()
            }
                .navigationTitle(OnlineRecipeCollectionFilter.followees.rawValue)
        ) {
            Label(OnlineRecipeCollectionFilter.followees.rawValue, systemImage: "person.2")
        }
    }

    private var discoverFeedLink: some View {
        NavigationLink(
            destination: OnlineRecipeCollectionView(
                viewModel: OnlineRecipeCollectionViewModel(filter: .everyone, settings: settings)) {
                EmptyView()
            }
                .navigationTitle(OnlineRecipeCollectionFilter.everyone.rawValue)
        ) {
            Label(OnlineRecipeCollectionFilter.everyone.rawValue, systemImage: "magnifyingglass")
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        Section(header: Text("Account")) {
            NavigationLink(
                destination: ownProfileView
            ) {
                Label("Profile", systemImage: "person")
            }

            NavigationLink(
                destination: followeesView
            ) {
                Label("Followees", systemImage: "person.2")
            }
        }
    }

    @ViewBuilder
    private var ownProfileView: some View {
        if let userId = settings.userId {
            ProfileView(viewModel: ProfileViewModel(userId: userId, settings: settings))
        } else {
            NotFoundView(entityName: "User")
        }
    }

    @ViewBuilder
    private var followeesView: some View {
        if let userId = settings.userId {
            FolloweeCollectionView(viewModel: FolloweeCollectionViewModel(userId: userId, settings: settings))
        } else {
            NotFoundView(entityName: "Followees")
        }
    }

    private var editToolbar: some View {
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

    // MARK: - Sheet Views

    @ViewBuilder
    private var sheetView: some View {
        switch viewModel.categoryType {
        case .recipe:
            addRecipeCategorySheet
        case .ingredient:
            addIngredientCategorySheet
        case .none:
            EmptyView()
        }
    }

    private var addRecipeCategorySheet: some View {
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

    private var addIngredientCategorySheet: some View {
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
 }

 struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(viewModel: SidebarViewModel(settings: UserSettings()), editMode: .constant(EditMode.inactive))
    }
 }
