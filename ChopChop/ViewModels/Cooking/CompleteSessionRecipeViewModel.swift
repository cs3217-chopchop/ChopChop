import Combine
import InflectorKit

class CompleteSessionRecipeViewModel: ObservableObject {
    @Published var recipeIngredients: [DeductibleIngredientViewModel] = []
    @Published var isSuccess = false

    private let storageManager = StorageManager()

    init(recipe: Recipe) {
        let ingredients = (try? storageManager.fetchIngredients()) ?? []

        recipeIngredients = recipe.ingredients.compactMap { recipeIngredient in
            // First check for exact matches, then case-insensitive matches, then plurality-insensitive matches
            let exactMatch = ingredients.first(where: { $0.name == recipeIngredient.name })
            let caseInsensitiveMatch = ingredients.first(where: {
                $0.name.localizedCaseInsensitiveCompare(recipeIngredient.name) == .orderedSame
            })
            let pluralityInsensitiveMatch = ingredients.first(where: {
                $0.name.singularized.localizedCaseInsensitiveCompare(recipeIngredient.name.singularized) == .orderedSame
            })

            guard let ingredient = exactMatch ?? caseInsensitiveMatch ?? pluralityInsensitiveMatch else {
                return nil
            }

            return DeductibleIngredientViewModel(ingredient: ingredient, recipeIngredient: recipeIngredient)
        }
    }

    func submit() {
        var ingredientsToSave: [Ingredient] = []
        // atomic
        for ingredientViewModel in recipeIngredients {
            ingredientViewModel.updateError(msg: "") // reset error

            guard let amount = Double(ingredientViewModel.deductBy) else {
                ingredientViewModel.updateError(msg: "Not a valid number")
                continue
            }

            guard let id = ingredientViewModel.ingredient.id,
                  var ingredient = try? storageManager.fetchIngredient(id: id) else {
                // publisher would have updated viewModels otherwise
                assertionFailure("Ingredient should exist in store")
                continue
            }

            guard let quantityUsed = try? Quantity(ingredientViewModel.unit, value: amount) else {
                ingredientViewModel.updateError(msg: "Not a valid number")
                continue
            }

            guard let sufficientAmount = try? ingredient.contains(quantity: quantityUsed) else {
                ingredientViewModel.updateError(msg: """
                    Not a valid unit. Change to \(quantityUsed.type == .count ? "mass/volume" : "count" )
                    """)
                continue
            }

            guard sufficientAmount else {
                ingredientViewModel.updateError(msg: "Insufficient quantity in ingredient store")
                continue
            }

            do {
                try ingredient.use(quantity: quantityUsed)
                ingredientsToSave.append(ingredient)
            } catch {
                assertionFailure("Ingredient should have sufficient quantity")
                continue
            }
        }

        guard (recipeIngredients.allSatisfy { $0.errorMsg.isEmpty }) else {
            return
        }

        // only do database operations here
        for var ingredient in ingredientsToSave {
            do {
                try storageManager.saveIngredient(&ingredient)
            } catch {
                assertionFailure("Couldn't save ingredient")
            }
        }

        isSuccess = recipeIngredients.allSatisfy { $0.errorMsg.isEmpty }
    }
}
