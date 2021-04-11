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
            Button(action: {
                viewModel.setRecipe()
            }) {
                Label("Download", systemImage: "square.and.arrow.down")
            }
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
            Text("Serves \(viewModel.recipeServingText)")
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
        ForEach(0..<viewModel.recipe.stepGraph.nodes.count, id: \.self) { idx in
            HStack(alignment: .top) {
                Text("Step \(idx + 1):")
                    .bold()
                Text(viewModel.recipe.stepGraph.topologicallySortedNodes[idx].label.content)
            }
        }.font(.body)
    }

    var averageRating: some View {
        HStack {
            Text("Average rating: ")
            StarsView(rating: viewModel.averageRating, maxRating: RatingScore.max)
                .frame(width: 200, height: 40, alignment: .center)
            Text(viewModel.ratingDetails)
        }.padding()
    }

}

struct OnlineRecipeView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static var previews: some View {
        OnlineRecipeView(viewModel: OnlineRecipeViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()), downloadRecipeViewModel: DownloadRecipeViewModel(), settings: UserSettings()))
    }
}
