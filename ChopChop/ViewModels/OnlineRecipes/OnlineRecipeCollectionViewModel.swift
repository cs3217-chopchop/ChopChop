import Combine
import Foundation

final class OnlineRecipeCollectionViewModel: ObservableObject {
    @Published private(set) var recipes: [OnlineRecipe] = []

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?

    @Published var downloadRecipeViewModel = DownloadRecipeViewModel()

    init(publisher: AnyPublisher<[OnlineRecipe], Error>) {
        recipesCancellable = publisher
            .catch { _ in
                Just<[OnlineRecipe]>([])
            }
            .eraseToAnyPublisher()
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }
    }

    init(recipe: OnlineRecipe) {
        self.recipes = [recipe]
    }

}
