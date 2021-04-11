import Foundation

final class OnlineRecipeCollectionViewModel: ObservableObject {
    private let filter: OnlineRecipeCollectionFilter
    @Published private(set) var recipes: [OnlineRecipe] = []

    private let storageManager = StorageManager()
    private let settings: UserSettings

    @Published var downloadRecipeViewModel = DownloadRecipeViewModel()

    init(filter: OnlineRecipeCollectionFilter, settings: UserSettings) {
        self.filter = filter
        self.settings = settings
    }

    func load() {
        if filter == .everyone {
            storageManager.fetchAllOnlineRecipes { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
        } else if filter == .followees {
            storageManager.fetchRecipesByUsers(userIds: settings.user?.followees ?? []) { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
        } else if filter == .own {
            storageManager.fetchRecipesByUsers(userIds: [settings.userId].compactMap { $0 }) { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
        }
    }

}

enum OnlineRecipeCollectionFilter: String {
    case everyone = "All Recipes"
    case followees = "Recipes from followees"
    case own = "My Published Recipes"
}
