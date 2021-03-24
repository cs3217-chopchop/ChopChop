import Combine

final class CookingSelectionViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var recipes: [RecipeInfo] = []
    @Published var selectedIngredients: Set<String> = [] // not sure how to rm this

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?
    private var recipeIngredientsCancellable: AnyCancellable?

    private let categoryIds: [Int64?]

    private(set) var sessionRecipeViewModel: SessionRecipeViewModel? {
        didSet {
            if sessionRecipeViewModel?.sessionRecipe.isCompleted == true {
                sessionRecipeViewModel = nil
            }
        }
    }

    init(categoryIds: [Int64?]) {
        self.categoryIds = categoryIds
        recipesCancellable = recipesPublisher()
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }
    }

    private func recipesPublisher() -> AnyPublisher<[RecipeInfo], Never> {
        $query.combineLatest($selectedIngredients).map { [self] query, _
            -> AnyPublisher<[RecipeInfo], Error> in
            storageManager.recipesPublisher(query: query,
                                            categoryIds: categoryIds,
                                            ingredients: [])
        }
        .map { recipesPublisher in
            recipesPublisher.catch { _ in
                Just<[RecipeInfo]>([])
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    func updateSessionRecipeViewModel(_ sessionRecipeViewModel: SessionRecipeViewModel?) {
        self.sessionRecipeViewModel = sessionRecipeViewModel
    }

}
