import SwiftUI

struct OnlineRecipeBySelfView: View {
    @ObservedObject var viewModel: OnlineRecipeBySelfViewModel

    var body: some View {
        HStack {
            OnlineRecipeView(viewModel: viewModel)
            Image(systemName: "trash")
                .onTapGesture {
                    viewModel.onDelete()
                }
        }
    }
}

struct OnlineRecipeBySelfView_Previews: PreviewProvider {
    // swiftlint:disable force_try
    static var previews: some View {
        OnlineRecipeBySelfView(viewModel: OnlineRecipeBySelfViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", steps: [], ingredients: [], ratings: [])))
    }
}
