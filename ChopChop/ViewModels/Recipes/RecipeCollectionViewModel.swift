import Combine
import Foundation
import UIKit

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
    var category: RecipeCategory? {
        guard categoryIds.compactMap({ $0 }).count == 1 else {
            return nil
        }

        return try? RecipeCategory(id: categoryIds.compactMap({ $0 }).first, name: title)
    }

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

    func getRecipeImage(recipe: RecipeInfo) -> UIImage? {
        guard let id = recipe.id else {
            return nil
        }

        return storageManager.fetchRecipeImage(name: String(id))
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
