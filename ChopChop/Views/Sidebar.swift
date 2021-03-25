import SwiftUI

 struct Sidebar: View {
    @ObservedObject var viewModel: SidebarViewModel

    let cookingSelectionViewModel: CookingSelectionViewModel

    @State private var sheetIsPresented = false

    var body: some View {
        List {
            cookingSection
            recipesSection
            ingredientsSection
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            HStack(spacing: 16) {
                if viewModel.editMode.isEditing {
                    Menu {
                        Button("Recipe Category", action: {
                            sheetIsPresented = true
                        })
                        Button("Ingredient Category", action: {})
                    } label: {
                        Text("Add")
                    }
                    .sheet(isPresented: $sheetIsPresented) {
                        Text("yolo")
                    }
                }

                EditButton()
            }
        }
        .navigationTitle(Text("ChopChop"))
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .environment(\.editMode, $viewModel.editMode)
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

//    var addRecipeCategorySheet: some View {
//        VStack {
//            Text("Add Recipe Category")
//                .font(.title)
//            TextField("Category", text: $categoryName)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            Button("Done", action: {
//                sheetIsPresented = false
//            })
//        }
//    }
//
//    var addIngredientCategorySheet: some View {
//        VStack {
//            Text("Add Ingredient Category")
//                .font(.title)
//            TextField("Category", text: $categoryName)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            Button("Done", action: {
//                sheetIsPresented = false
//            })
//        }
//    }

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
            .deleteDisabled(!viewModel.editMode.isEditing)

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
            .deleteDisabled(!viewModel.editMode.isEditing)

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
        Sidebar(viewModel: SidebarViewModel(),
                cookingSelectionViewModel: CookingSelectionViewModel(categoryIds: []))
    }
 }
