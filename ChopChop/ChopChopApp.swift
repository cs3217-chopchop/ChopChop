import SwiftUI
import Firebase

@main
struct ChopChopApp: App {
    @StateObject var settings = UserSettings()
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            if settings.userId == nil {
                CreateUserProfileView(viewModel: CreateUserProfileViewModel(settings: settings))
            } else {
                NavigationView {
                    MainView(viewModel: MainViewModel())
                }
                .environmentObject(settings)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    UserDefaults.standard.removeObject(forKey: "userId") // TODO
    FirebaseApp.configure()
    return true
  }
}
