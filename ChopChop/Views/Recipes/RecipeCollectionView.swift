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
            .padding([.leading, .trailing])

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
        .padding(.top)
    }

    @ViewBuilder
    func RecipeRow(recipe: RecipeInfo) -> some View {
        if let fetchedRecipe = viewModel.getRecipe(info: recipe) {
            NavigationLink(
                destination: RecipeView(
                    viewModel: RecipeViewModel(
                        recipe: fetchedRecipe, settings: settings)
                )
            ) {
                HStack(alignment: .top) {
                    Image("recipe")
                        .resizable()
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
        if let fetchedRecipe = viewModel.getRecipe(info: recipe) {
            NavigationLink(
                destination: RecipeView(
                    viewModel: RecipeViewModel(
                        recipe: fetchedRecipe, settings: settings)
                )
            ) {
                GridTileImage(recipe: recipe)
            }

        }
    }

    func GridTileImage(recipe: RecipeInfo) -> some View {
        Image("recipe")
            .resizable()
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(10)
            .clipped()
            .overlay(
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .black, location: 0.5)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(10)
                        .opacity(0.8)
                    VStack(alignment: .leading) {
                        Text(recipe.name)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        RecipeCaption(recipe: recipe)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            )
            .padding([.leading, .trailing], 8)
    }

    func RecipeCaption(recipe: RecipeInfo) -> some View {
        VStack(alignment: .leading) {
            Text("""
                Serves \(recipe.servings.removeZerosFromEnd()) \(recipe.servings == 1 ? "person" : "people")
                """)
            HStack(spacing: 0) {
                Text("Difficulty: ")

                if let difficulty = recipe.difficulty {
                    ForEach(0..<difficulty.rawValue, id: \.self) { _ in
                        Image(systemName: "star.fill")
                    }

                    ForEach(difficulty.rawValue..<5, id: \.self) { _ in
                        Image(systemName: "star")
                    }
                } else {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star")
                    }
                }
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
