import UIKit

class IngredientViewModel {
    let ingredient: Ingredient

    init(ingredient: Ingredient) {
        self.ingredient = ingredient
    }

    var name: String {
        ingredient.name
    }

    var batches: [IngredientBatch] {
        ingredient.batches
    }

    var image: UIImage {
        ingredient.image ?? UIImage()
    }
}
