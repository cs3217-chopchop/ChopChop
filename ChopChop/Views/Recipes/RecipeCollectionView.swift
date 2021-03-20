import SwiftUI

struct RecipeCollectionView: View {
    @ObservedObject var viewModel: RecipeCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search recipes...")
            HStack {
                Spacer()
                MultiselectPicker("Filter by ingredient",
                                  selections: $viewModel.selectedIngredients,
                                  options: viewModel.recipeIngredients)
            }
            .padding([.leading, .trailing])
            List(viewModel.recipes) { recipe in
                RecipeRow(recipe: recipe)
            }
        }
        .navigationTitle(Text(viewModel.title))
        .onDisappear {
            viewModel.query = ""
            viewModel.selectedIngredients.removeAll()
        }
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
                    .foregroundColor(.secondary)
                }
            }
            .padding([.top, .bottom], 6)
        }
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: ""))
    }
}
