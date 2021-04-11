import SwiftUI

struct OnlineRecipeCollectionView<Content: View>: View {
    @ObservedObject var viewModel: OnlineRecipeCollectionViewModel
    @ObservedObject var downloadRecipeViewModel: DownloadRecipeViewModel
    @EnvironmentObject var settings: UserSettings
    let content: Content

    init(viewModel: OnlineRecipeCollectionViewModel, @ViewBuilder content: @escaping() -> Content) {
        self.viewModel = viewModel
        self.downloadRecipeViewModel = viewModel.downloadRecipeViewModel
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content

            if viewModel.recipes.isEmpty {
                NotFoundView(entityName: "Recipes")
                    .padding()
            } else {
                VStack(spacing: 20) {
                    ForEach(viewModel.recipes) { recipe in
                        if recipe.userId == settings.userId {
                            OnlineRecipeBySelfView(
                                viewModel: OnlineRecipeBySelfViewModel(
                                    recipe: recipe,
                                    downloadRecipeViewModel: downloadRecipeViewModel, settings: settings))
                        } else {
                            OnlineRecipeByUserView(
                                viewModel: OnlineRecipeByUserViewModel(
                                    recipe: recipe,
                                    downloadRecipeViewModel: downloadRecipeViewModel, settings: settings))
                        }
                    }
                }
            }
        }.background(EmptyView().sheet(isPresented: $downloadRecipeViewModel.isShow) {
            DownloadRecipeView(viewModel: downloadRecipeViewModel)
        })
    }
}

struct OnlineRecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineRecipeCollectionView(viewModel: OnlineRecipeCollectionViewModel(publisher:
                                                                                StorageManager().allRecipesPublisher())) {
            EmptyView()
        }
    }
}
