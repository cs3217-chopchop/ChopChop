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
            storageManager.fetchAllRecipes { onlineRecipes, _ in
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

enum OnlineRecipeCollectionFilter {
    case everyone
    case followees
    case own
}
