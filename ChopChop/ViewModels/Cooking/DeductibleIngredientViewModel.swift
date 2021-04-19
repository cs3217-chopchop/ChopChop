import SwiftUI

/**
 Represents a view model for a view of an ingredient to be deducted from the ingredient inventory after a recipe has been completed.
 */
final class DeductibleIngredientViewModel: ObservableObject {
    /// The ingredient that is being used to make the recipe.
    let ingredient: Ingredient

    /// The quantity of the ingredient used.
    @Published var quantity: String
    /// The unit of the quantity.
    @Published var unit: QuantityUnit

    @Published var errorMessages: [String] = []

    init(ingredient: Ingredient, recipeIngredient: RecipeIngredient) {
        quantity = recipeIngredient.quantity.value.removeZerosFromEnd()
        unit = recipeIngredient.quantity.unit
        self.ingredient = ingredient
    }

    /**
     Formats the given string input and updates the quantity with the result.
     */
    func setQuantity(_ quantity: String) {
        self.quantity = String(quantity.filter { "0123456789.".contains($0) })
            .components(separatedBy: ".")
            .prefix(2)
            .joined(separator: ".")
    }

    /**
     Converts the information in the fields to an `Ingredient`

     - Throws:
        - `QuantityError.invalidQuantity` if the format of the quantity field is invalid.
        - `IngredientError.insufficientQuantity` if the inventory does not contain sufficient quantity.
     */
    func convertToIngredient() throws -> Ingredient {
        guard let value = Double(quantity) else {
            throw QuantityError.invalidQuantity
        }

        var ingredient = self.ingredient
        try ingredient.use(quantity: Quantity(unit, value: value))

        return ingredient
    }
}

extension DeductibleIngredientViewModel: Equatable {
    static func == (lhs: DeductibleIngredientViewModel, rhs: DeductibleIngredientViewModel) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension DeductibleIngredientViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
