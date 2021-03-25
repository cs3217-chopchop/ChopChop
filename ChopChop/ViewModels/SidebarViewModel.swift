import Combine
import SwiftUI

final class SidebarViewModel: ObservableObject {
    @Published var editMode = EditMode.inactive
    @Published private(set) var recipeCategories: [RecipeCategory] = []
    @Published private(set) var ingredientCategories: [IngredientCategory] = []

    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

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

    func deleteRecipeCategories(at offsets: IndexSet) {
        do {
            let ids = offsets.compactMap { recipeCategories[$0].id }
            try storageManager.deleteRecipeCategories(ids: ids)
        } catch {
            alertTitle = "Database error"
            alertMessage = "\(error)"

            alertIsPresented = true
        }
    }

    func deleteIngredientCategories(at offsets: IndexSet) {
        do {
            let ids = offsets.compactMap { ingredientCategories[$0].id }
            try storageManager.deleteIngredientCategories(ids: ids)
        } catch {
            alertTitle = "Database error"
            alertMessage = "\(error)"

            alertIsPresented = true
        }
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
