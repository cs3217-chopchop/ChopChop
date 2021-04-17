import Combine
import SwiftUI

/**
 Represents a view model of a view of the sidebar.
 */
final class SidebarViewModel: ObservableObject {
    /// The collection of recipe categories.
    @Published private(set) var recipeCategories: [RecipeCategory] = []
    /// The collection of ingredient categories.
    @Published private(set) var ingredientCategories: [IngredientCategory] = []

    /// Alert fields
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    /// Form fields
    @Published var categoryName = ""
    @Published var categoryType: CategoryType?
    @Published var sheetIsPresented = false

    private let settings: UserSettings
    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(settings: UserSettings) {
        self.settings = settings

        recipeCategoriesPublisher
            .sink { [weak self] categories in
                self?.recipeCategories = categories
            }
            .store(in: &cancellables)

        ingredientCategoriesPublisher
            .sink { [weak self] categories in
                self?.ingredientCategories = categories
            }
            .store(in: &cancellables)
    }

    /**
     Adds a new recipe or ingredient category.
     */
    func addCategory() {
        switch categoryType {
        case .recipe:
            addRecipeCategory(name: categoryName)
        case .ingredient:
            addIngredientCategory(name: categoryName)
        case .none:
            return
        }

        categoryName = ""
        categoryType = nil
    }

    private func addRecipeCategory(name: String) {
        do {
            var category = try RecipeCategory(name: name)
            try storageManager.saveRecipeCategory(&category)
        } catch {
            if let message = (error as? LocalizedError)?.errorDescription {
                alertTitle = "Error"
                alertMessage = message
            } else {
                alertTitle = "Database error"
                alertMessage = "\(error)"
            }

            alertIsPresented = true
        }
    }

    private func addIngredientCategory(name: String) {
        do {
            var category = try IngredientCategory(name: name)
            try storageManager.saveIngredientCategory(&category)
        } catch {
            if let message = (error as? LocalizedError)?.errorDescription {
                alertTitle = "Error"
                alertMessage = message
            } else {
                alertTitle = "Database error"
                alertMessage = "\(error)"
            }

            alertIsPresented = true
        }
    }

    /**
     Deletes the recipe categories at the given indices of the recipe category array.
     */
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

    /**
     Deletes the ingredient categories at the given indices of the ingredient category array.
     */
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

    private var recipeCategoriesPublisher: AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }

    private var ingredientCategoriesPublisher: AnyPublisher<[IngredientCategory], Never> {
        storageManager.ingredientCategoriesPublisher()
            .catch { _ in
                Just<[IngredientCategory]>([])
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Online Recipe Publishers

    /**
     Returns a publisher that publishes all online recipes.
     */
    var allOnlineRecipesPublisher: AnyPublisher<[OnlineRecipe], Error> {
        storageManager.allRecipesPublisher()
    }

    /**
     Returns a publisher that publishes all online recipes by the user's followees.
     */
    var followeesOnlineRecipePublisher: AnyPublisher<[OnlineRecipe], Error> {
        guard let userId = settings.userId else {
            fatalError("No user id stored")
        }

        return storageManager.allFolloweesRecipePublisher(userId: userId)
    }
}

extension SidebarViewModel {
    enum CategoryType {
        case recipe, ingredient
    }
}
