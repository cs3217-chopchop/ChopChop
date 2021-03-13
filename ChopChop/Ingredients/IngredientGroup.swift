class IngredientGroup {
    private(set) var name: String
    private(set) var ingredients: [IngredientEditable]

    init(name: String) {
        self.name = name
        self.ingredients = []
    }

    func add(_ addedIngredient: IngredientEditable) {
        let existingIngredient = ingredients.filter { ingredient in
            ingredient.name == addedIngredient.name
                && ingredient.
        }
    }
}
