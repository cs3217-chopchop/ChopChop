import SwiftUI

struct DownloadModal: View {
    @ObservedObject var viewModel: OnlineRecipeByUserViewModel

    var body: some View {
        TextField("Save as", text: $viewModel.saveAs)
            .frame(width: 150, height: 50, alignment: .center)
            .border(Color.primary, width: 1)
            .multilineTextAlignment(.center)
            .padding()
        Text(viewModel.errorMessage)
            .foregroundColor(.red)
    }
}

struct DownloadModal_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static var previews: some View {
        DownloadModal(viewModel: OnlineRecipeByUserViewModel(recipe: try! OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.hard, cuisine: "Chinese", steps: [], ingredients: [], ratings: [], created: Date())))
    }
}
