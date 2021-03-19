import Combine

final class RecipeCollectionViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var recipes: [RecipeInfo] = []
    @Published private(set) var recipeIngredients: [String: [Int64]] = [:]
    @Published var selectedIngredients: Set<String> = []

    let title: String
    let categoryIds: [Int64]

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?
    private var recipeIngredientsCancellable: AnyCancellable?

    init(title: String, categoryIds: [Int64] = []) {
        self.title = title
        self.categoryIds = categoryIds

        recipesCancellable = recipesPublisher()
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }
        recipeIngredientsCancellable = recipeIngredientsPublisher()
            .sink { [weak self] ingredients in
                self?.recipeIngredients = ingredients
            }
    }

    private func recipesPublisher() -> AnyPublisher<[RecipeInfo], Never> {
        $query.combineLatest($selectedIngredients).map { [self] query, selectedIngredients
            -> AnyPublisher<[RecipeInfo], Error> in
            storageManager.recipesFilteredByNameAndCategoryPublisher(query: query,
                                                                     categoryIds: categoryIds,
                                                                     ingredients: Array(selectedIngredients))
        }
        .map { recipesPublisher in
            recipesPublisher.catch { _ in
                Just<[RecipeInfo]>([])
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    private func recipeIngredientsPublisher() -> AnyPublisher<[String: [Int64]], Never> {
        storageManager.recipeIngredientsPublisher()
            .catch { _ in
                Just<[String: [Int64]]>([:])
            }
            .eraseToAnyPublisher()
    }
}
