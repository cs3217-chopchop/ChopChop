import SwiftUI

class DeductibleIngredientViewModel: ObservableObject {
    let recipeIngredient: RecipeIngredient
    let ingredient: Ingredient
    @Published var deductBy: String
    @Published var isError = false

    init(ingredient: Ingredient, recipeIngredient: RecipeIngredient) {
        self.ingredient = ingredient
        self.recipeIngredient = recipeIngredient
        deductBy = String(recipeIngredient.quantity.value)
    }

    func updateError(isError: Bool) {
        self.isError = isError
    }

}
