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
                    Text("Add recipe")
                }
                Spacer()
                MultiselectPicker("Filter by ingredient",
                                  selections: $viewModel.selectedIngredients,
                                  options: viewModel.recipeIngredients)
            }
            .padding([.leading, .trailing])

            if viewModel.recipes.isEmpty {
                notFoundView
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
        .onAppear {
            viewModel.query = ""
            viewModel.selectedIngredients.removeAll()
        }
    }

    var notFoundView: some View {
        VStack(spacing: 10) {
            Image(systemName: "text.badge.xmark")
                .font(.system(size: 60))
            Text("No recipes found")
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .foregroundColor(.secondary)
    }

    var listView: some View {
        List(viewModel.recipes) { recipe in
            RecipeRow(recipe: recipe)
        }
    }

    var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(viewModel.recipes) { recipe in
                    NavigationLink(
                        destination: Text(recipe.name)
                    ) {
                        GridTile(recipe: recipe)
                    }
                }
            }
            .padding([.bottom, .leading, .trailing])
        }
        .padding(.top)
    }

    func RecipeRow(recipe: RecipeInfo) -> some View {
        NavigationLink(
            destination: Text(recipe.name)
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

    func GridTile(recipe: RecipeInfo) -> some View {
        Image("recipe")
            .resizable()
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity)
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
                    ForEach(0..<difficulty.rawValue) { _ in
                        Image(systemName: "star.fill")
                    }

                    ForEach(difficulty.rawValue..<5) { _ in
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
