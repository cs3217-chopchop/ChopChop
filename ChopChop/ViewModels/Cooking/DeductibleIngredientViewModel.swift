import SwiftUI

class DeductibleIngredientViewModel: ObservableObject {
    let recipeIngredient: RecipeIngredient
    let ingredient: Ingredient
    @Published var deductBy: String
    @Published var unit: QuantityUnit
    @Published var errorMsg = ""

    init(ingredient: Ingredient, recipeIngredient: RecipeIngredient) {
        self.ingredient = ingredient
        self.recipeIngredient = recipeIngredient
        deductBy = String(recipeIngredient.quantity.value)
        unit = recipeIngredient.quantity.unit
    }

    func updateUnit(unit: QuantityUnit) {
        self.unit = unit
    }

    func updateError(msg: String) {
        errorMsg = msg
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
