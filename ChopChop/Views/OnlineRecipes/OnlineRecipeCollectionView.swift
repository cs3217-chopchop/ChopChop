import SwiftUI

struct OnlineRecipeCollectionView: View {
    @ObservedObject var viewModel: OnlineRecipeCollectionViewModel
    @ObservedObject var downloadRecipeViewModel: DownloadRecipeViewModel

    init(viewModel: OnlineRecipeCollectionViewModel) {
        self.viewModel = viewModel
        self.downloadRecipeViewModel = viewModel.downloadRecipeViewModel
    }

    var body: some View {
        if viewModel.recipes.isEmpty {
            NotFoundView(entityName: "Recipes")
        } else {
            ScrollView {
                if viewModel.userIds == [USER_ID] {
                    ForEach(viewModel.recipes) { recipe in
                        OnlineRecipeBySelfView(viewModel: OnlineRecipeBySelfViewModel(recipe: recipe))
                    }
                } else {
                    ForEach(viewModel.recipes) { recipe in
                        OnlineRecipeByUserView(viewModel:
                                                OnlineRecipeByUserViewModel(recipe: recipe,
                                                                            downloadRecipeViewModel: downloadRecipeViewModel))
                    }
                }
            }.sheet(isPresented: $downloadRecipeViewModel.isShow) {
                DownloadRecipeView(viewModel: downloadRecipeViewModel)
            }
        }

    }
}

struct OnlineRecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineRecipeCollectionView(viewModel: OnlineRecipeCollectionViewModel(userIds: []))
    }
}
