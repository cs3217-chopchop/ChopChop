import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Sidebar(recipeCategories: viewModel.recipeCategories, ingredientCategories: viewModel.ingredientCategories)

        // TODO: Show latest recipes cooked, ingredients expiry date overview etc
        Text("Welcome to ChopChop!")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
