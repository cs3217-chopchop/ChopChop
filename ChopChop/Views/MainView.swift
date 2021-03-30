import SwiftUI
import FirebaseFirestore

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @State var editMode = EditMode.inactive

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Sidebar(viewModel: SidebarViewModel(), editMode: $editMode)
        RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: "All Recipes",
                                                                  categoryIds: viewModel.recipeCategories
                                                                    .compactMap { $0.id } + [nil]))
        Button("Press") {
            click()
        }
    }
    private func click() {
        let db = FirebaseDatabase()
        db.removeRecipeRating(onlineRecipeId: "4oD1x5S7aqusvV6EKf9Y", rating: RecipeRating(userId: "2", score: .excellent))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
