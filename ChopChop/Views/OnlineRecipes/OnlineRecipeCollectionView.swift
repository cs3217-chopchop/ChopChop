import SwiftUI

struct OnlineRecipeCollectionView: View {
    @ObservedObject var viewModel: OnlineRecipeCollectionViewModel
    @ObservedObject var downloadRecipeViewModel = DownloadRecipeViewModel()

    var body: some View {
        ScrollView {
            if viewModel.recipes.isEmpty {
                NotFoundView(entityName: "Recipes")
            } else {
                if viewModel.userIds == [USER_ID] {
                    ForEach(viewModel.recipes) { recipe in
                        OnlineRecipeBySelfView(viewModel: OnlineRecipeBySelfViewModel(recipe: recipe))
                    }
                } else {
                    ForEach(viewModel.recipes) { recipe in
                        OnlineRecipeByUserView(viewModel:
                                                OnlineRecipeByUserViewModel(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel))
                    }
                }
            }
        }
        .background(EmptyView().sheet(isPresented: $downloadRecipeViewModel.isShow) {
            DownloadRecipeView(viewModel: downloadRecipeViewModel)
        })
    }
}

struct OnlineRecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineRecipeCollectionView(viewModel: OnlineRecipeCollectionViewModel(userIds: []))
    }
}
