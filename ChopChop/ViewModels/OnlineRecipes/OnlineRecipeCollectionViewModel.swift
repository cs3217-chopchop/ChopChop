import Combine
import Foundation

final class OnlineRecipeCollectionViewModel: ObservableObject {
    @Published private(set) var recipes: [OnlineRecipe] = []
    let userIds: [String]

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?

    let downloadRecipeViewModel = DownloadRecipeViewModel()

    init(userIds: [String]) {
        self.userIds = userIds

        recipesCancellable = recipesPublisher()
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }
    }

    private func recipesPublisher() -> AnyPublisher<[OnlineRecipe], Never> {
       storageManager.allRecipesByUsersPublisher(userIds: userIds)
        .catch { _ in
            Just<[OnlineRecipe]>([])
        }
        .eraseToAnyPublisher()
    }

}
