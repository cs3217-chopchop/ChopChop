import Combine
import Foundation

final class OnlineRecipeCollectionViewModel: ObservableObject {
    @Published private(set) var recipes: [OnlineRecipe] = []

    private let storageManager = StorageManager()

    @Published var downloadRecipeViewModel = DownloadRecipeViewModel()

    init(userIds: [String]?) {
        guard let userIds = userIds else {
            storageManager.fetchAllRecipes(completion: onLoadOnlineRecipes(onlineRecipes:error:))
            return
        }
        storageManager.fetchRecipesByUsers(userIds: userIds, completion: onLoadOnlineRecipes(onlineRecipes:error:))
    }

    private func onLoadOnlineRecipes(onlineRecipes: [OnlineRecipe], error: Error?) {
        recipes = onlineRecipes
    }

}
