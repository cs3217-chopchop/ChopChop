import SwiftUI

struct OnlineRecipeView: View {
    @ObservedObject var viewModel: OnlineRecipeViewModel

    var body: some View {
        VStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
            Text(viewModel.recipe.name)
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(Capsule())
            recipeDetails
            Divider()
            averageRating
        }

    }

    var recipeDetails: some View {
        VStack(alignment: .center) {
            Text("General").font(.title).underline()
            general
            Spacer()
            Text("Ingredients").font(.title).underline()
            ingredient
            Spacer()
            Text("Instructions").font(.title).underline()
            instruction
        }
        .padding()
    }

    var general: some View {
        VStack {
            Text("Serves \(viewModel.recipe.servings.removeZerosFromEnd()) \(viewModel.recipe.servings == 1 ? "person" : "people")")
            HStack {
                Text("Difficulty: ")
                DifficultyView(difficulty: viewModel.recipe.difficulty)
            }
            HStack {
                Text("Cuisine: ")
                Text(viewModel.recipe.cuisine ?? "Unspecified")
            }
        }.font(.body)
    }

    var ingredient: some View {
        VStack(alignment: .center) {
            ForEach(viewModel.recipe.ingredients, id: \.self.description) { ingredient in
                Text(ingredient.description)
            }
        }.font(.body)
    }

    var instruction: some View {
        VStack(alignment: .leading) {
            ForEach(0..<viewModel.recipe.steps.count, id: \.self) { idx in
                Text("Step \(idx + 1): \(viewModel.recipe.steps[idx])")
            }
        }.font(.body)
    }

    var averageRating: some View {
        HStack {
            Text("Average rating: ")
            StarsView(rating: viewModel.averageRating, maxRating: RatingScore.max)
            Text(viewModel.ratingDetails)
        }.frame(width: 400, height: 50, alignment: .center)
    }

}

struct OnlineRecipeView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static var previews: some View {
        OnlineRecipeView(viewModel: OnlineRecipeViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", steps: [], ingredients: [], ratings: [], created: Date())))
    }
}
