import SwiftUI

/**
 Represents a view model for a view of an ingredient required to make a recipe.
 */
final class RecipeIngredientRowViewModel: ObservableObject {
    /// Form fields
    @Published var name: String
    @Published var quantity: String
    @Published var unit: QuantityUnit

    init(name: String = "", quantity: String = "", unit: QuantityUnit = .count) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
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
     Converts the information in the form fields to a `RecipeIngredient`

     - Throws:
        - `QuantityError.invalidQuantity` if the format of the quantity field is invalid.
        - `RecipeIngredientError.invalidName` if the name field trimmed is empty.
     */
    func convertToIngredient() throws -> RecipeIngredient {
        guard let value = Double(quantity) else {
            throw QuantityError.invalidQuantity
        }

        return try RecipeIngredient(name: name, quantity: Quantity(unit, value: value))
    }
}

extension RecipeIngredientRowViewModel: Equatable {
    static func == (lhs: RecipeIngredientRowViewModel, rhs: RecipeIngredientRowViewModel) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension RecipeIngredientRowViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
