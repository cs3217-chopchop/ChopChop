import Combine
import Foundation

/**
 Represents a view model for the main view of the application.
 */
final class MainViewModel: ObservableObject {
    /// A collection of recipe categories.
    @Published private(set) var recipeCategories: [RecipeCategory] = []

    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        recipeCategoriesPublisher
            .sink { [weak self] categories in
                self?.recipeCategories = categories
            }
            .store(in: &cancellables)
    }

    private var recipeCategoriesPublisher: AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
