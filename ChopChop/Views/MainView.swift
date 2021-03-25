import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    let cookingSelectionViewModel: CookingSelectionViewModel
    @State var editMode = EditMode.inactive

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        cookingSelectionViewModel = CookingSelectionViewModel(categoryIds: viewModel.recipeCategories
                                                                .compactMap { $0.id } + [nil])
    }

    var body: some View {
        Sidebar(viewModel: SidebarViewModel(),
                cookingSelectionViewModel: cookingSelectionViewModel,
                editMode: $editMode)

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
