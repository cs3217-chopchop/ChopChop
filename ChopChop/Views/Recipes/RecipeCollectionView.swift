import SwiftUI

struct RecipeCollectionView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var viewModel: RecipeCollectionViewModel

    let columns = [
        GridItem(),
        GridItem(),
        GridItem()
    ]

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search recipes...")
            HStack {
                NavigationLink(destination: RecipeFormView(viewModel: RecipeFormViewModel())) {
                    Image(systemName: "plus")
                }
                Spacer()
                MultiselectPicker("Filter by ingredient",
                                  selections: $viewModel.selectedIngredients,
                                  options: viewModel.recipeIngredients)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))

            if viewModel.recipes.isEmpty {
                NotFoundView(entityName: "Recipes")
            } else {
                switch settings.viewType {
                case .list:
                    listView
                case .grid:
                    gridView
                }
            }
        }
        .navigationTitle(Text(viewModel.title))
        .toolbar {
            HStack {
                Text("View type:")
                Picker("View by", selection: $settings.viewType) {
                    Text("List").tag(UserSettings.ViewType.list)
                    Text("Grid").tag(UserSettings.ViewType.grid)
                }
            }
        }
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .onAppear {
            viewModel.query = ""
            viewModel.selectedIngredients.removeAll()
        }
    }

    var listView: some View {
        List {
            ForEach(viewModel.recipes) { recipe in
                RecipeRow(recipe: recipe)
            }
            .onDelete(perform: viewModel.deleteRecipes)
        }
    }

    var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(viewModel.recipes) { recipe in
                    GridTile(recipe: recipe)
                        .contextMenu {
                            Button(action: {
                                guard let index = viewModel.recipes.firstIndex(where: { $0.id == recipe.id }) else {
                                    return
                                }

                                viewModel.deleteRecipes(at: [index])
                            }) {
                                Label("Delete Recipe", systemImage: "trash")
                            }
                        }
                }
            }
            .padding([.bottom, .leading, .trailing])
        }
    }

    @ViewBuilder
    func RecipeImage(recipe: RecipeInfo) -> some View {
        if let image = viewModel.getRecipeImage(recipe: recipe) {
            Image(uiImage: image)
                .resizable()
        } else {
            Image("recipe")
                .resizable()
        }
    }

    @ViewBuilder
    func RecipeRow(recipe: RecipeInfo) -> some View {
        if let id = recipe.id {
            NavigationLink(
                destination: RecipeView(viewModel: RecipeViewModel(id: id, settings: settings))
            ) {
                HStack(alignment: .top) {
                    RecipeImage(recipe: recipe)
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                        .clipped()

                    VStack(alignment: .leading) {
                        Text(recipe.name)
                            .lineLimit(1)
                        RecipeCaption(recipe: recipe)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.top, .bottom], 6)
            }
        }
    }

    @ViewBuilder
    func GridTile(recipe: RecipeInfo) -> some View {
        if let id = recipe.id {
            NavigationLink(
                destination: RecipeView(viewModel: RecipeViewModel(id: id, settings: settings))
            ) {
                GridTileImage(recipe: recipe)
            }
        }
    }

    @ViewBuilder
    func GridTileImage(recipe: RecipeInfo) -> some View {
        RecipeImage(recipe: recipe)
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(10)
            .clipped()
            .overlay(
                GridTileOverlay(recipe: recipe)
            )
            .padding([.leading, .trailing], 8)
    }

    func GridTileOverlay(recipe: RecipeInfo) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .foregroundColor(.clear)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                           startPoint: .top,
                                           endPoint: .bottom))
                .cornerRadius(10)
                .opacity(0.8)
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .foregroundColor(.white)
                    .lineLimit(1)
                RecipeCaption(recipe: recipe)
                    .foregroundColor(.white)
            }
            .padding()
        }
    }

    func RecipeCaption(recipe: RecipeInfo) -> some View {
        VStack(alignment: .leading) {
            Text("""
                Serves \(recipe.servings.removeZerosFromEnd()) \(recipe.servings == 1 ? "person" : "people")
                """)
            HStack(spacing: 0) {
                Text("Difficulty: ")
                DifficultyView(difficulty: recipe.difficulty)
            }
        }
        .font(.caption)
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: ""))
    }
}
