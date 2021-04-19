import SwiftUI

/**
 Represents a view of a collection of recipes published online.
 */
struct OnlineRecipeCollectionView<Content: View>: View {
    @ObservedObject var viewModel: OnlineRecipeCollectionViewModel
    @ObservedObject var downloadRecipeViewModel: DownloadRecipeViewModel
    @EnvironmentObject var settings: UserSettings

    /// Content to be rendered on top of the collection of recipes in the scroll view.
    let content: Content

    init(viewModel: OnlineRecipeCollectionViewModel, @ViewBuilder content: @escaping() -> Content) {
        self.viewModel = viewModel
        self.downloadRecipeViewModel = viewModel.downloadRecipeViewModel
        self.content = content()
    }

    var body: some View {
        ZStack {
            ScrollView {
                content

                if viewModel.recipes.isEmpty {
                    NotFoundView(entityName: "Recipes")
                        .padding()
                } else {
                    recipes
                }
            }

            ProgressView(isShow: $viewModel.isLoading)
        }.sheet(isPresented: $downloadRecipeViewModel.isShow) {
            DownloadRecipeView(viewModel: downloadRecipeViewModel)
        }.onAppear {
            viewModel.load()
        }
    }

    private var recipes: some View {
        VStack(spacing: 20) {
            ForEach(viewModel.recipes) { recipe in
                if recipe.creatorId == settings.userId {
                    recipeBySelf(recipe)
                } else {
                    recipeByOtherUser(recipe)
                }
            }
        }
    }

    private func recipeBySelf(_ recipe: OnlineRecipe) -> some View {
        OnlineRecipeBySelfView(
            viewModel: OnlineRecipeBySelfViewModel(
                recipe: recipe,
                downloadRecipeViewModel: downloadRecipeViewModel,
                settings: settings,
                reload: viewModel.load))
    }

    private func recipeByOtherUser(_ recipe: OnlineRecipe) -> some View {
        OnlineRecipeByUserView(
            viewModel: OnlineRecipeByUserViewModel(
                recipe: recipe,
                downloadRecipeViewModel: downloadRecipeViewModel,
                settings: settings))
    }
}
