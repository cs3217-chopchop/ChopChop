class IngredientGroup<Ingredient: IngredientEditable> {
    private(set) var name: String
    private(set) var ingredients: [Ingredient]

    init(name: String) {
        self.name = name
        self.ingredients = []
    }

    func add(_ addedIngredient: Ingredient) {
        let existingIngredients = ingredients.filter { ingredient in
            ingredient.name == addedIngredient.name
        }

        for ingredient in existingIngredients {
            
        }
    }
}
