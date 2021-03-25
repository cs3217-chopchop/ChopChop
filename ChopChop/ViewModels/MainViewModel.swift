import Combine
import Foundation

final class MainViewModel: ObservableObject {
    @Published private(set) var recipeCategories: [RecipeCategory] = []

    private let storageManager = StorageManager()
    private var recipeCategoriesCancellable: AnyCancellable?

    var currentCookingSession: SessionRecipe?

    init() {
        recipeCategoriesCancellable = recipeCategoriesPublisher()
            .sink { [weak self] categories in
                self?.recipeCategories = categories
            }
    }

    private func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
