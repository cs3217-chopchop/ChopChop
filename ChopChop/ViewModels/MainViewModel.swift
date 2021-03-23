import Combine
import Foundation

final class MainViewModel: ObservableObject {
    @Published private(set) var recipeCategories: [RecipeCategory] = []
    @Published private(set) var ingredientCategories: [IngredientCategory] = []

    private let storageManager = StorageManager()
    private var recipeCategoriesCancellable: AnyCancellable?
    private var ingredientCategoriesCancellable: AnyCancellable?

    var currentCookingSession: SessionRecipe?

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

    func deleteRecipeCategories(at offsets: IndexSet) {
        let ids = offsets.compactMap { recipeCategories[$0].id }
        try? storageManager.deleteRecipeCategories(ids: ids)
    }

    func deleteIngredientCategories(at offsets: IndexSet) {
        let ids = offsets.compactMap { ingredientCategories[$0].id }
        try? storageManager.deleteIngredientCategories(ids: ids)
    }

    private func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }

    private func ingredientCategoriesPublisher() -> AnyPublisher<[IngredientCategory], Never> {
        storageManager.ingredientCategoriesPublisher()
            .catch { _ in
                Just<[IngredientCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
