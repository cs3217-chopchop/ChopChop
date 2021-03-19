import Combine

final class MainViewModel: ObservableObject {
    @Published private(set) var recipeCategories: [RecipeCategory] = []
    @Published private(set) var ingredientCategories: [IngredientCategory] = []

    private let storageManager = StorageManager()
    private var recipeCategoriesCancellable: AnyCancellable?
    private var ingredientCategoriesCancellable: AnyCancellable?

    init() {
        recipeCategoriesCancellable = recipeCategoriesPublisher()
            .sink { [weak self] categories in
                self?.recipeCategories = categories
            }

        ingredientCategoriesCancellable = ingredientCategoriesPublisher()
            .sink { [weak self] categories in
                self?.ingredientCategories = categories
            }
    }

    private func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesOrderedByNamePublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }

    private func ingredientCategoriesPublisher() -> AnyPublisher<[IngredientCategory], Never> {
        storageManager.ingredientCategoriesOrderedByNamePublisher()
            .catch { _ in
                Just<[IngredientCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
