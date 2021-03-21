import SwiftUI
import Combine

class CompleteSessionRecipeViewModel: ObservableObject {
    @Published var deductibleIngredientsViewModels: [DeductibleIngredientViewModel] = []
    private var recipe: Recipe
    private let onClose: () -> Void

    private let storageManager = StorageManager()
    private(set) var ingredientsInStore: [IngredientInfo] = []
    private var ingredientsCancellable: AnyCancellable?

    init(recipe: Recipe, onClose: @escaping () -> Void) {
        self.recipe = recipe
        self.onClose = onClose

        ingredientsCancellable = ingredientsPublisher()
            .sink { [weak self] ingredients in
                self?.ingredientsInStore = ingredients
                self?.deductibleIngredientsViewModels = self?.convertToDeductibleIngredientViewModels(recipeIngredients: recipe.ingredients) ?? []
            }

    }

    func submit() {
        var ingredientsToSave: [Ingredient] = []
        // atomic
        for ingredientViewModel in deductibleIngredientsViewModels {
            ingredientViewModel.updateError(isError: false) // reset error

            guard let amount = Double(ingredientViewModel.deductBy) else {
                ingredientViewModel.updateError(isError: true)
                continue
            }

            guard let id = ingredientViewModel.ingredient.id else {
                continue
            }
            guard let ingredient = try? storageManager.fetchIngredient(id: id) else {
                continue
            }

            let quantityType = ingredient.quantityType
            do {
                try ingredient.use(quantity: Quantity(quantityType, value: amount))
                ingredientsToSave.append(ingredient)
            } catch {
                ingredientViewModel.updateError(isError: true)
                continue
            }
        }

        // only do database operations here
        for var ingredient in ingredientsToSave {
            do {
                try storageManager.saveIngredient(&ingredient)
            } catch {
                assertionFailure("Couldn't save ingredient")
            }
        }

        onClose()
    }

    private func ingredientsPublisher() -> AnyPublisher<[IngredientInfo], Never> {
        return storageManager.ingredientsOrderedByNamePublisher()
            .catch { _ in
                Just<[IngredientInfo]>([])
            }
            .eraseToAnyPublisher()
    }

    private func convertToDeductibleIngredientViewModels(recipeIngredients: [RecipeIngredient]) -> [DeductibleIngredientViewModel] {

        recipeIngredients.compactMap { recipeIngredient -> DeductibleIngredientViewModel? in
            guard let mappedIngredientId = (ingredientsInStore.first { $0.name == recipeIngredient.name })?.id else {
                return nil
            }
            guard let mappedIngredient = try? storageManager.fetchIngredient(id: mappedIngredientId) else {
                return nil
            }

            let estimatedQuantity = recipeIngredient.quantity.type == mappedIngredient.quantityType ? recipeIngredient.quantity.value : 0

            return DeductibleIngredientViewModel(ingredient: mappedIngredient, estimatedQuantity: estimatedQuantity)
        }
    }

}
