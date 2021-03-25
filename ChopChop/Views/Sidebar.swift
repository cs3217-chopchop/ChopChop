import SwiftUI

 struct Sidebar: View {
    @ObservedObject var viewModel: SidebarViewModel
    @Binding var editMode: EditMode

    var body: some View {
        List {
            cookingSection
            recipesSection
            ingredientsSection
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
            NavigationLink(
                destination: RecipeCollectionView(viewModel:
                                                    RecipeCollectionViewModel(
                                                        title: "All Recipes",
                                                        categoryIds: viewModel.recipeCategories
                                                            .compactMap { $0.id } + [nil]))
            ) {
                Label("All Recipes", systemImage: "tray.2")
            }

            ForEach(viewModel.recipeCategories) { category in
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
            .onDelete(perform: viewModel.deleteRecipeCategories)
            .deleteDisabled(!editMode.isEditing)

            NavigationLink(
                destination: RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: "Uncategorised"))
            ) {
                Label("Uncategorised", systemImage: "questionmark.folder")
            }
        }
    }

    var ingredientsSection: some View {
        Section(header: Text("Ingredients")) {
            NavigationLink(
                destination: IngredientCollectionView(viewModel:
                                                    IngredientCollectionViewModel(
                                                        title: "All Ingredients",
                                                        categoryIds: viewModel.ingredientCategories
                                                            .compactMap { $0.id } + [nil]))
            ) {
                Label("All Ingredients", systemImage: "tray.2")
            }

            ForEach(viewModel.ingredientCategories) { category in
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
            .onDelete(perform: viewModel.deleteIngredientCategories)
            .deleteDisabled(!editMode.isEditing)

            NavigationLink(
                destination: IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: "Uncategorised"))
            ) {
                Label("Uncategorised", systemImage: "questionmark.folder")
            }
        }
    }
 }

 struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(viewModel: SidebarViewModel(), editMode: .constant(EditMode.inactive))
    }
 }
