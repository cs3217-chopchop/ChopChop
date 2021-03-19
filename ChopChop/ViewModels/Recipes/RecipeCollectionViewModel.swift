import Combine

final class RecipeCollectionViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var recipes: [RecipeInfo] = []
    @Published private(set) var ingredients: [String: [Int64]] = [:]
    @Published var category: RecipeCategory

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?
    private var ingredientsCancellable: AnyCancellable?

    init(category: RecipeCategory) {
        self.category = category

        recipesCancellable = recipesPublisher()
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }
        ingredientsCancellable = ingredientsPublisher()
            .sink { [weak self] ingredients in
                self?.ingredients = ingredients
            }
    }

    private func recipesPublisher() -> AnyPublisher<[RecipeInfo], Never> {
        $query.map { [self] query -> AnyPublisher<[RecipeInfo], Error> in
            print(query)
            if let id = category.id {
                let ids = id == 0 ? [] : [id]

                return storageManager.recipesFilteredByNameAndCategoryPublisher(query: query, categoryIds: ids)
            } else {
                return storageManager.recipesFilteredByNamePublisher(query)
            }
        }
        .map { recipesPublisher in
            recipesPublisher.catch { _ in
                Just<[RecipeInfo]>([])
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    private func ingredientsPublisher() -> AnyPublisher<[String: [Int64]], Never> {
        storageManager.recipeIngredientsPublisher()
            .catch { _ in
                Just<[String: [Int64]]>([:])
            }
            .eraseToAnyPublisher()
    }
}
