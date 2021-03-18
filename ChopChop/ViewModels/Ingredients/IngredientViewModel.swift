class IngredientViewModel {
    let ingredient: Ingredient

    init(ingredient: Ingredient) {
        self.ingredient = ingredient
    }

    var ingredientName: String {
        ingredient.name
    }

    var ingredientBatches: [IngredientBatch] {
        ingredient.batches
    }
}
