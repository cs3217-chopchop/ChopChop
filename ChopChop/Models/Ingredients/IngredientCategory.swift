/**
 Represents a collection of ingredients grouped under a category..
 */
class IngredientCategory {
    private(set) var name: String
    private(set) var ingredients: [Ingredient]

    init(name: String) {
        self.name = name
        self.ingredients = []
    }

    /**
     Adds the given ingredient into the category.
     If the category contains an existing ingredient with the same name and quantity type,
     combines the given ingredient instead.
     */
    func add(_ addedIngredient: Ingredient) {
        let sameIngredient = ingredients.first { ingredient in
            ingredient == addedIngredient
        }

        guard let existingIngredient = sameIngredient else {
            ingredients.append(addedIngredient)
            return
        }

        do {
            try existingIngredient.combine(with: addedIngredient)
        } catch {
            return
        }
    }

    /**
     Removes the given ingredient from the category.
     If such an ingredient does not exist, do nothing.
     */
    func remove(_ removedIngredient: Ingredient) {
        ingredients.removeAll { ingredient in
            ingredient == removedIngredient
        }
    }
}
