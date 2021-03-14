/**
 Represents a collection of ingredients.
 */
class IngredientGroup {
    private(set) var name: String
    private(set) var ingredients: [Ingredient]

    init(name: String) {
        self.name = name
        self.ingredients = []
    }

    func add(_ addedIngredient: Ingredient) {
        let existingIngredient = ingredients.filter { ingredient in
            ingredient.name == addedIngredient.name
        }

        var ingredientCombined = false

        for ingredient in existingIngredient {
            do {
                try ingredient.combine(with: addedIngredient)
                ingredientCombined = true
                break
            } catch {
                continue
            }
        }

        if !ingredientCombined {
            ingredients.append(addedIngredient)
        }
    }

    func remove(_ removedIngredient: Ingredient) {
        ingredients.removeAll { ingredient in
            ingredient == removedIngredient
        }
    }
}
