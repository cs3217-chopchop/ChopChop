import SwiftUI

struct OnlineRecipeBySelfView: View {
    @ObservedObject var viewModel: OnlineRecipeBySelfViewModel

    var body: some View {
        VStack(spacing: 0) {
            OnlineRecipeView(viewModel: viewModel)

            Divider()
            Button(action: viewModel.onDelete) {
                Label("Unpublish", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary, lineWidth: 4)
        )
        .padding([.vertical], 50)
        .padding([.horizontal], 100)
    }
}

struct OnlineRecipeBySelfView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static var previews: some View {
        OnlineRecipeBySelfView(viewModel: OnlineRecipeBySelfViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()), downloadRecipeViewModel: DownloadRecipeViewModel(), settings: UserSettings()))
    }
}
