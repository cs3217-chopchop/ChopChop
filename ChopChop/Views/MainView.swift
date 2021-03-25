import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    let cookingSelectionViewModel: CookingSelectionViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        cookingSelectionViewModel = CookingSelectionViewModel(categoryIds: viewModel.recipeCategories
                                                                .compactMap { $0.id } + [nil])
    }

    var body: some View {
        Sidebar(viewModel: SidebarViewModel(),
                cookingSelectionViewModel: cookingSelectionViewModel)

        RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: "All Recipes",
                                                                  categoryIds: viewModel.recipeCategories
                                                                    .compactMap { $0.id } + [nil]))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
