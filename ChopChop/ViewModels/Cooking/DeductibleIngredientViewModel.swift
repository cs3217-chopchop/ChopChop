import SwiftUI

class DeductibleIngredientViewModel: ObservableObject {
    let recipeIngredient: RecipeIngredient
    let ingredient: Ingredient
    @Published var deductBy: String
    @Published var unit: QuantityType
    @Published var errorMsg = ""

    init(ingredient: Ingredient, recipeIngredient: RecipeIngredient) {
        self.ingredient = ingredient
        self.recipeIngredient = recipeIngredient
        deductBy = String(recipeIngredient.quantity.value)
        unit = recipeIngredient.quantity.type
    }

    func updateUnit(unit: QuantityType) {
        self.unit = unit
    }

    func updateError(msg: String) {
        errorMsg = msg
    }

}