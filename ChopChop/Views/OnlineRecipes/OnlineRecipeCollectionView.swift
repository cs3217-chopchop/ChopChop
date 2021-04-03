import SwiftUI

struct OnlineRecipeCollectionView: View {
    @ObservedObject var viewModel: OnlineRecipeCollectionViewModel

    var body: some View {
        ScrollView {
            if viewModel.userIds == [USER_ID] {
                ForEach(viewModel.recipes) { recipe in
                    OnlineRecipeBySelfView(viewModel: OnlineRecipeBySelfViewModel(recipe: recipe))
                }
            } else {
                ForEach(viewModel.recipes) { recipe in
                    OnlineRecipeByUserView(viewModel: OnlineRecipeByUserViewModel(recipe: recipe))
                }
            }
        }
    }
}

struct OnlineRecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineRecipeCollectionView(viewModel: OnlineRecipeCollectionViewModel(userIds: []))
    }
}
