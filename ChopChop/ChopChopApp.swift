import SwiftUI

@main
struct ChopChopApp: App {
    @StateObject var settings = UserSettings()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView(viewModel: MainViewModel())
            }
            .environmentObject(settings)
        }
    }
}
