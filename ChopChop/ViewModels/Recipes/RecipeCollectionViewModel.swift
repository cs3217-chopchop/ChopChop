import Combine
import Foundation
import UIKit

/**
 Represents a view model for a view of a collection of recipes.
 */
final class RecipeCollectionViewModel: ObservableObject {
    /// The name of the collection of recipes.
    let title: String
    /// The recipes displayed in the view is the union of recipes in
    /// each of the categories in this array, represented by their ids.
    let categoryIds: [Int64?]

    /// The collection of recipes displayed in the view.
    @Published private(set) var recipes: [RecipeInfo] = []
    /// The ingredients required to make the displayed recipe.
    @Published private(set) var recipeIngredients: Set<String> = []

    /// Search fields
    @Published var query = ""
    @Published var selectedIngredients: Set<String> = []

    /// Alert fields
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(title: String, categoryIds: [Int64?] = [nil]) {
        self.title = title
        self.categoryIds = categoryIds

        recipesPublisher
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }
            .store(in: &cancellables)

        recipeIngredientsPublisher
            .sink { [weak self] ingredients in
                self?.recipeIngredients = Set(ingredients)
            }
            .store(in: &cancellables)
    }

    /**
     Deletes the recipes at the given indices of the recipe array.
     */
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

    /**
     Returns the corresponding image of the recipe, or `nil` if such an image does not exist in local storage.
     */
    func getRecipeImage(recipe: RecipeInfo) -> UIImage? {
        guard let id = recipe.id else {
            return nil
        }

        return storageManager.fetchRecipeImage(name: String(id))
    }

    /**
     Resets the search fields to their default values.
     */
    func resetSearchFields() {
        query = ""
        selectedIngredients.removeAll()
    }

    private var recipesPublisher: AnyPublisher<[RecipeInfo], Never> {
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

    private var recipeIngredientsPublisher: AnyPublisher<[String], Never> {
        storageManager.recipeIngredientsPublisher(categoryIds: categoryIds)
            .catch { _ in
                Just<[String]>([])
            }
            .eraseToAnyPublisher()
    }
}
