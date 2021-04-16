import Foundation

final class OnlineRecipeCollectionViewModel: ObservableObject {
    private let filter: OnlineRecipeCollectionFilter?
    private let userIds: [String]?
    @Published private(set) var recipes: [OnlineRecipe] = []

    private let storageManager = StorageManager()
    private let settings: UserSettings

    @Published var downloadRecipeViewModel = DownloadRecipeViewModel()

    init(filter: OnlineRecipeCollectionFilter, settings: UserSettings) {
        self.filter = filter
        self.userIds = nil
        self.settings = settings
    }

    init(userIds: [String], settings: UserSettings) {
        self.userIds = userIds
        self.filter = nil
        self.settings = settings
    }

    func load() {
        if let userIds = userIds {
            storageManager.fetchOnlineRecipes(userIds: userIds) { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
            return
        }

        if filter == .everyone {
            storageManager.fetchAllOnlineRecipes { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
        } else if filter == .followees {
            storageManager.fetchOnlineRecipes(userIds: settings.user?.followees ?? []) { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
        } else if filter == .own {
            storageManager.fetchOnlineRecipes(userIds: [settings.userId].compactMap { $0 }) { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
        }
    }

}

enum OnlineRecipeCollectionFilter: String {
    case everyone = "Discover"
    case followees = "Recipes from followees"
    case own = "Own"
}
