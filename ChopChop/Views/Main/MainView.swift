import SwiftUI
import FirebaseFirestore
import Combine

/**
 Represents the main view of the application.
 */
struct MainView: View {
    @EnvironmentObject var settings: UserSettings
    @StateObject var viewModel: MainViewModel
    @State var editMode = EditMode.inactive

    var body: some View {
        Sidebar(viewModel: SidebarViewModel(settings: settings), editMode: $editMode)
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
