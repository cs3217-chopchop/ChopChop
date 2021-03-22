import SwiftUI
import Combine

class CompleteSessionRecipeViewModel: ObservableObject {
    @Published var deductibleIngredientsViewModels: [DeductibleIngredientViewModel] = []
    @Published var isSuccess = false
    private var recipe: Recipe

    private let storageManager = StorageManager()
    private(set) var ingredientsInStore: [IngredientInfo] = []
    private var ingredientsCancellable: AnyCancellable?

    init(recipe: Recipe) {
        self.recipe = recipe

        ingredientsCancellable = ingredientsPublisher()
            .sink { [weak self] ingredients in
                self?.ingredientsInStore = ingredients
                if self?.isSuccess == false {
                    self?.deductibleIngredientsViewModels = self?.convertToDeductibleIngredientViewModels(recipeIngredients: recipe.ingredients) ?? []
                }
            }

        // swiftlint:disable line_length
        let expiry = Calendar.current.date(byAdding: .day, value: 10, to: Date())
        guard var butter = try? Ingredient(name: "Butter", type: .count, batches: [IngredientBatch(quantity: Quantity(.count, value: 4), expiryDate: expiry)]),
              var milk = try? Ingredient(name: "Milk", type: .volume, batches: [IngredientBatch(quantity: Quantity(.count, value: 2_000), expiryDate: expiry)]) else {
            return
        }
        try? StorageManager().deleteAllIngredients()
        try? StorageManager().saveIngredient(&butter)
        try? StorageManager().saveIngredient(&milk)
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
                assertionFailure("Ingredient should have id")
                continue
            }
            guard let ingredient = try? storageManager.fetchIngredient(id: id) else {
                continue
            }

            let quantityType = ingredient.batches[0].quantity.type
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

        isSuccess = deductibleIngredientsViewModels.allSatisfy { !$0.isError }
    }

    private func ingredientsPublisher() -> AnyPublisher<[IngredientInfo], Never> {
        storageManager.ingredientsPublisher()
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

            let estimatedQuantity = recipeIngredient.quantity.baseType == mappedIngredient.quantityType ? recipeIngredient.quantity.value : 0

            return DeductibleIngredientViewModel(ingredient: mappedIngredient, estimatedQuantity: estimatedQuantity)
        }
    }

}
