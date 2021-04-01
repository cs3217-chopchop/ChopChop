import SwiftUI
import FirebaseFirestore
import Combine

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
//        ForEach(viewModel.recipes) { user in
//            Text(user.name)
//        }
//        Text(viewModel.recipes?.name ?? "hello")
        Button("Press") {
            click()
        }

    }
    private func click() {
        var storage = StorageManager()
        var firebase = FirebaseDatabase()

        do {
//            let r = try OnlineRecipe(id: "QCIXZuYAIF3OYYWxhNi1",
//                userId: "hello", name: "test", servings: 3.0,
//                difficulty: .easy, cuisine: "asian", steps: ["first"],
//                ingredients: [OnlineIngredientDetails(name: "fist", quantity: Quantity(.count, value: 5))],
//                ratings: [RecipeRating(userId: "AZ1fSU6cm6EUiXZQMI1e", score: .adequate)])
//            try storage.rateRecipe(recipeId: "ITs4kCUj2d3eoydNDbQQ", userId: "AZ1fSU6cm6EUiXZQMI1e", rating: .adequate)
            try firebase.removeUserRecipeRating(
                userId: "AZ1fSU6cm6EUiXZQMI1e", rating: UserRating(recipeOnlineId: "QCIXZuYAIF3OYYWxhNi1", score: .adequate))
        } catch {
            print(error)
        }

//        db.addFollowee(userId: id, followeeId: "randomId")
//        db.addFollowee(userId: id, followeeId: "randomId2")
//        db.addUserRecipeRating(userId: id, rating: UserRating(recipeOnlineId: "4oD1x5S7aqusvV6EKf9Y", score: .adequate))
//        db.addUserRecipeRating(userId: id, rating: UserRating(recipeOnlineId: "ITs4kCUj2d3eoydNDbQQ", score: .great))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
