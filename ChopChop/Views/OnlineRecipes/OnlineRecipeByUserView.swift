import SwiftUI

struct OnlineRecipeByUserView: View {
    @ObservedObject var viewModel: OnlineRecipeByUserViewModel

    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            OnlineRecipeView(viewModel: viewModel)

            Divider()

            HStack {
                if viewModel.isShowingRating {
                    StarsView(rating: Double(viewModel.ownRating?.score.rawValue ?? 0),
                              maxRating: RatingScore.max, onTap: viewModel.tapRating)
                        .frame(width: 200, height: 40, alignment: .center)
                }
                rateRecipeButton
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary, lineWidth: 4)
        )
        .padding([.vertical], 50)
        .padding([.horizontal], 100)
    }

    var rateRecipeButton: some View {
        Button(action: {
            if viewModel.isShowingRating {
                if viewModel.ownRating != nil {
                    viewModel.removeRating()
                }
            }
            viewModel.toggleShowRating()
        }) {
            if viewModel.isShowingRating {
                if viewModel.ownRating != nil {
                    Text("Remove Rating")
                } else {
                    Text("Close")
                }
            } else {
                HStack {
                    Image(systemName: "star")
                    Text("Rate Recipe")
                }
            }
        }
        .padding()
    }
}

struct OnlineRecipeByUserView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static var previews: some View {
        OnlineRecipeByUserView(viewModel: OnlineRecipeByUserViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()), downloadRecipeViewModel: DownloadRecipeViewModel(), settings: UserSettings()))

    }
}
