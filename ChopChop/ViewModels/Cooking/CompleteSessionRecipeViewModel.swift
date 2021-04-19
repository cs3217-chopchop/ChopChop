import Combine
import InflectorKit

/**
 Represents a view model for a view of the completion of a recipe being made.
 */
final class CompleteSessionRecipeViewModel: ObservableObject {
    /// The ingredients to be deducted from the ingredient inventory.
    @Published var deductibleIngredients: [DeductibleIngredientViewModel] = []

    private let storageManager = StorageManager()

    init(recipe: Recipe) {
        let ingredients = (try? storageManager.fetchIngredients()) ?? []

        deductibleIngredients = recipe.ingredients.compactMap { recipeIngredient in
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

    /**
     Completes the recipe being made and saves the updates to the ingredient inventory.
     */
    func completeRecipe() -> Bool {
        guard validateIngredients() else {
            return false
        }

        do {
            var ingredients = try deductibleIngredients.map { try $0.convertToIngredient() }
            try storageManager.saveIngredients(&ingredients)

            return true
        } catch {
            return false
        }
    }

    private func validateIngredients() -> Bool {
        for deductibleIngredient in deductibleIngredients {
            deductibleIngredient.errorMessages = []

            guard let value = Double(deductibleIngredient.quantity),
                  let quantity = try? Quantity(deductibleIngredient.unit, value: value) else {
                deductibleIngredient.errorMessages.append(QuantityError.invalidQuantity.errorDescription ?? "")
                continue
            }

            guard let hasSufficientAmount = try? deductibleIngredient.ingredient.contains(quantity: quantity) else {
                deductibleIngredient.errorMessages.append("""
                    \(QuantityError.incompatibleTypes.errorDescription ?? "") \
                    Change type to \(quantity.type == .count ? "mass/volume" : "count").
                    """)
                continue
            }

            if !hasSufficientAmount {
                deductibleIngredient.errorMessages.append("Insufficient ingredient quantity to deduct ingredient.")
            }
        }

        return deductibleIngredients.allSatisfy { $0.errorMessages.isEmpty }
    }
}
