import Combine

final class RecipeCollectionViewModel: ObservableObject {
    @Published var query: String = "" {
        didSet {
            recipesCancellable = recipesPublisher()
                .sink { [weak self] recipes in
                    self?.recipes = recipes
                }
        }
    }
    @Published private(set) var recipes: [RecipeInfo] = []
    @Published private(set) var ingredients: [String: [Int64]] = [:]
    @Published var selectedCategory: RecipeCategory?

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?
    private var ingredientsCancellable: AnyCancellable?

    init(selectedCategory: RecipeCategory?) {
        self.selectedCategory = selectedCategory

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
        if let category = selectedCategory, let id = category.id {
            let ids = id == 0 ? [] : [id]

            return storageManager.recipesFilteredByNameAndCategoryPublisher(query: query, categoryIds: ids)
                .catch { _ in
                    Just<[RecipeInfo]>([])
                }
                .eraseToAnyPublisher()
        } else {
            return storageManager.recipesFilteredByNamePublisher(query)
                .catch { _ in
                    Just<[RecipeInfo]>([])
                }
                .eraseToAnyPublisher()
        }
    }

    private func ingredientsPublisher() -> AnyPublisher<[String: [Int64]], Never> {
        storageManager.recipeIngredientsPublisher()
            .catch { _ in
                Just<[String: [Int64]]>([:])
            }
            .eraseToAnyPublisher()
    }
}
