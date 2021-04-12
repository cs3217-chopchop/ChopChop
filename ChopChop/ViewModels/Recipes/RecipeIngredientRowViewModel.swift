import SwiftUI

class RecipeIngredientRowViewModel: ObservableObject {
    @Published var amount: String = "" {
        didSet {
            ensureValidAmount()
        }
    }
    @Published var unit: QuantityType = .count
    @Published var ingredientName: String = ""

    init(amount: String, unit: QuantityType, ingredientName: String) {
        self.amount = amount
        self.unit = unit
        self.ingredientName = ingredientName
    }

    init() {}

    func ensureValidAmount() {
        let filtered = amount.filter { "0123456789.".contains($0) }
        if filtered != amount {
            amount = filtered
        }
    }

    func convertToIngredient() throws -> RecipeIngredient {
        guard let quantity = Double(amount) else {
            throw RecipeFormError.invalidIngredientQuantity
        }
        return try RecipeIngredient(name: ingredientName, quantity: Quantity(unit, value: quantity))
    }
}
