/**
 Represents a collection of ingredients grouped under a category..
 */
class IngredientCategory {
    var id: Int64?
    private(set) var name: String
    private(set) var ingredients: [Ingredient]

    init(name: String, id: Int64? = nil, ingredients: [Ingredient] = []) {
        self.id = id
        self.name = name

        ingredients.forEach { $0.ingredientCategoryId = id }
        self.ingredients = ingredients
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
            addedIngredient.ingredientCategoryId = id
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

    /**
     Returns the ingredient with the given name and quantity type,
     or `nil` if it does not exist in the category.
     */
    func getIngredient(name: String, type: QuantityType) -> Ingredient? {
        ingredients.first { ingredient in
            ingredient.name == name && ingredient.quantityType == type
        }
    }
}
