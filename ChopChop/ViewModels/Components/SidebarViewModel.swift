import Combine

final class SidebarViewModel: ObservableObject {
    @Published var recipeCategories: [RecipeCategory] = []
    @Published var ingredientCategories: [RecipeCategory] = []

    private let storageManager = StorageManager()
    private var recipeCategoriesCancellable: AnyCancellable?

    init() {
        recipeCategoriesCancellable = recipeCategoriesPublisher()
            .sink { [weak self] categories in
                self?.recipeCategories = [RecipeCategory(name: "All Recipes")] + categories
                    + [RecipeCategory(id: 0, name: "Uncategorised")]
            }
    }

    private func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesOrderedByNamePublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
