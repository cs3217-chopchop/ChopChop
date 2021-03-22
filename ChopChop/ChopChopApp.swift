import SwiftUI

@main
struct ChopChopApp: App {
    @StateObject var settings = UserSettings()

    var body: some Scene {
        WindowGroup {
//            RecipeFormView(viewModel: RecipeFormViewModel())
            NavigationView {
                MainView(viewModel: MainViewModel())
            }
            .environmentObject(settings)
        }
    }
}
