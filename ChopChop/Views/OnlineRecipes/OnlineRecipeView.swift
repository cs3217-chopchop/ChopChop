import SwiftUI

struct OnlineRecipeView: View {
    @ObservedObject var viewModel: OnlineRecipeViewModel

    var body: some View {
        VStack {

            Text(viewModel.recipe.name)
            Text("""
                Serves \(viewModel.recipe.servings.removeZerosFromEnd()) \(viewModel.recipe.servings == 1 ? "person" : "people")
                """)
            HStack(spacing: 0) {
                Text("Difficulty: ")
                DifficultyView(difficulty: viewModel.recipe.difficulty)
            }
            Text("Cuisine: " + viewModel.recipe.cuisine)

            Text("Ingredient:")
            ForEach(viewModel.recipe.ingredients, id: \.self) { ingredient in
                Text(ingredient.description)
            }

            Text("Steps:")
            ForEach(viewModel.recipe.steps, id: \.self) { step in
                Text(step)
            }

            Divider()

            Text("Average rating")
            StarsView(rating: viewModel.averageRating, maxRating: RatingScore.excellent.rawValue, onTap: () -> Void)
        }

    }

}

struct OnlineRecipeView_Previews: PreviewProvider {
    // swiftlint:disable force_try
    static var previews: some View {
        OnlineRecipeView(viewModel: OnlineRecipeViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", steps: [], ingredients: [], ratings: [])))
    }
}
