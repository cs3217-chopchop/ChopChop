import SwiftUI

struct OnlineRecipeByUserView: View {
    @ObservedObject var viewModel: OnlineRecipeByUserViewModel

    var body: some View {
        VStack {
            Text("Created by: \(viewModel.creatorName)")
            OnlineRecipeView(viewModel: viewModel)

            HStack {
                Text("Own rating:")
                StarsView(rating: Double(viewModel.ownRating?.score.rawValue ?? 0),
                          maxRating: RatingScore.max, onTap: viewModel.tapRating)
                    .frame(width: 200, height: 40, alignment: .center)
            }

            if viewModel.ownRating != nil {
                Button(action: {
                    viewModel.removeRating()
                }) {
                    Text("Remove rating")
                }
            }

            Button(action: {
                viewModel.setRecipe()
            }) {
                Label("Download", systemImage: "square.and.arrow.down")
            }.padding()

        }
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary, lineWidth: 4)
        )
        .padding([.vertical], 50)
        .padding([.horizontal], 100)
    }

}

struct OnlineRecipeByUserView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static var previews: some View {
        OnlineRecipeByUserView(viewModel: OnlineRecipeByUserViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", steps: [], stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()), downloadRecipeViewModel: DownloadRecipeViewModel(), settings: UserSettings()))

    }
}
