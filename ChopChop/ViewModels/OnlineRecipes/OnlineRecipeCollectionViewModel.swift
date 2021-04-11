import Combine
import Foundation

final class OnlineRecipeCollectionViewModel: ObservableObject {
    @Published private(set) var recipes: [OnlineRecipe] = []

    let userIds: [String]?
    private let storageManager = StorageManager()

    @Published var downloadRecipeViewModel = DownloadRecipeViewModel()

    init(userIds: [String]?) {
        self.userIds = userIds
    }

    func onLoad() {
        guard let userIds = userIds else {
            storageManager.fetchAllRecipes { onlineRecipes, _ in
                self.recipes = onlineRecipes
            }
            return
        }
        storageManager.fetchRecipesByUsers(userIds: userIds) { onlineRecipes, _ in
            self.recipes = onlineRecipes
        }
    }

}
