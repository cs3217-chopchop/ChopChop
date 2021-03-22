import SwiftUI

class DeductibleIngredientViewModel: ObservableObject {
    let ingredient: Ingredient
    @Published var deductBy: String
    @Published var isError = false

    init(ingredient: Ingredient, estimatedQuantity: Double) {
        self.ingredient = ingredient
        deductBy = String(estimatedQuantity)
    }

    func updateError(isError: Bool) {
        self.isError = isError
    }

}
