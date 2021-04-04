import SwiftUI

struct OnlineRecipeCollectionView: View {
    @ObservedObject var viewModel: OnlineRecipeCollectionViewModel
    @ObservedObject var downloadRecipeViewModel: DownloadRecipeViewModel
    @EnvironmentObject var settings: UserSettings

    init(viewModel: OnlineRecipeCollectionViewModel) {
        self.viewModel = viewModel
        self.downloadRecipeViewModel = viewModel.downloadRecipeViewModel
    }

    var body: some View {
        if viewModel.recipes.isEmpty {
            NotFoundView(entityName: "Recipes")
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.recipes) { recipe in
                            if viewModel.userIds == [settings.userId] {
                                OnlineRecipeBySelfView(viewModel: OnlineRecipeBySelfViewModel(recipe: recipe, settings: settings))
                            } else {
                                OnlineRecipeByUserView(viewModel:
                                                        OnlineRecipeByUserViewModel(recipe: recipe,

                                                                                    downloadRecipeViewModel: downloadRecipeViewModel,
                                                                                    settings: settings))
                            }
                    }
                }
            }.background(EmptyView().sheet(isPresented: $downloadRecipeViewModel.isShow) {
                DownloadRecipeView(viewModel: downloadRecipeViewModel)
            })
        }

    }
}

struct OnlineRecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineRecipeCollectionView(viewModel: OnlineRecipeCollectionViewModel(userIds: []))
    }
}
