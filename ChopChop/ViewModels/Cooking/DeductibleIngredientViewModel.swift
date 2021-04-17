import SwiftUI

final class DeductibleIngredientViewModel: ObservableObject {
    @Published var quantity: String
    @Published var type: QuantityUnit
    @Published var errorMessages: [String] = []

    let ingredient: Ingredient

    init(ingredient: Ingredient, recipeIngredient: RecipeIngredient) {
        quantity = recipeIngredient.quantity.value.description
        type = recipeIngredient.quantity.unit
        self.ingredient = ingredient
    }

    func setQuantity(_ quantity: String) {
        self.quantity = String(quantity.filter { "0123456789.".contains($0) })
            .components(separatedBy: ".")
            .prefix(2)
            .joined(separator: ".")
    }

    // TODO: Change when ingredient becomes struct
    func convertToIngredient() throws -> Ingredient {
        guard let value = Double(quantity) else {
            throw QuantityError.invalidQuantity
        }

        try ingredient.use(quantity: Quantity(type, value: value))

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
