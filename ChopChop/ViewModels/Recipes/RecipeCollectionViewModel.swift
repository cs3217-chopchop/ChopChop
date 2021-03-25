import Combine
import Foundation

final class RecipeCollectionViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var recipes: [RecipeInfo] = []
    @Published private(set) var recipeIngredients: Set<String> = []
    @Published var selectedIngredients: Set<String> = []

    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    let title: String
    let categoryIds: [Int64?]

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?
    private var recipeIngredientsCancellable: AnyCancellable?

    init(title: String, categoryIds: [Int64?] = [nil]) {
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

    func deleteRecipes(at offsets: IndexSet) {
        do {
            let ids = offsets.compactMap { recipes[$0].id }
            try storageManager.deleteRecipes(ids: ids)
        } catch {
            alertTitle = "Database error"
            alertMessage = "\(error)"

            alertIsPresented = true
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

    func getRecipe(info: RecipeInfo) -> Recipe? {
        guard let id = info.id else {
            fatalError("Missing recipe id.")
        }

        return try? storageManager.fetchRecipe(id: id)
    }
}
