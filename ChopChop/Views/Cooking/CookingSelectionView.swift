import SwiftUI

struct CookingSelectionView: View {
    @ObservedObject var viewModel: CookingSelectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search recipes to Cook...")
            listView
        }
        .navigationTitle(Text("Cooking"))
        .onAppear {
            viewModel.query = ""
        }

    }

    var listView: some View {
        List(viewModel.recipes) { recipe in
            RecipeRow(recipe: recipe)
        }
    }

    func RecipeRow(recipe: RecipeInfo) -> some View {
        NavigationLink(
            destination: SessionRecipeView(viewModel: SessionRecipeViewModel(recipeInfo: recipe))
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

struct CookingSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: ""))
    }
}
