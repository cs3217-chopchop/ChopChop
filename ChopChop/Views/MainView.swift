import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @State var editMode = EditMode.inactive

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if USER_ID == nil {
            CreateUserProfileView(viewModel: CreateUserProfileViewModel())
        } else {
            Sidebar(viewModel: SidebarViewModel(), editMode: $editMode)
            RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: "All Recipes",
                                                                      categoryIds: viewModel.recipeCategories
                                                                        .compactMap { $0.id } + [nil]))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
