import Combine

final class RecipeCollectionViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var recipes: [RecipeInfo] = []
    @Published private(set) var recipeIngredients: Set<String> = []
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
                self?.recipeIngredients = Set(ingredients)
            }
    }

    private func recipesPublisher() -> AnyPublisher<[RecipeInfo], Never> {
        $query.combineLatest($selectedIngredients).map { [self] query, selectedIngredients
            -> AnyPublisher<[RecipeInfo], Error> in
            storageManager.recipesPublisher(query: query,
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

    private func recipeIngredientsPublisher() -> AnyPublisher<[String], Never> {
        storageManager.recipeIngredientsPublisher(categoryIds: categoryIds)
            .catch { _ in
                Just<[String]>([])
            }
            .eraseToAnyPublisher()
    }
}
