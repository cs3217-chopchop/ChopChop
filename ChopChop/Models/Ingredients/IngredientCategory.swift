import GRDB
import Combine

/**
 Represents a collection of ingredients grouped under a category.
 
 Invariants:
 - The `ingredientCategoryId` of all ingredients contained in this category is the same as the category's `id`.
 */
class IngredientCategory: FetchableRecord {
    var id: Int64?
    private(set) var name: String
    private(set) var ingredients: [Ingredient]

    init(name: String, id: Int64? = nil, ingredients: [Ingredient] = []) {
        self.id = id
        self.name = name

        ingredients.forEach { $0.ingredientCategoryId = id }
        self.ingredients = ingredients
    }

    required init(row: Row) {
        id = row["id"]
        name = row["name"]
        ingredients = []

        if let categoryId = id {
            let storageManager = StorageManager()
            storageManager.ingredientsFilteredByCategoryOrderedByNamePublisher(ids: [categoryId])
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] infos in
                    let ingredientIds = infos.compactMap { $0.id }
                    let ingredients = ingredientIds.compactMap { try? storageManager.fetchIngredient(id: $0) }
                    self?.ingredients = ingredients
                })
        }
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
        guard ingredients.contains(removedIngredient) else {
            return
        }

        ingredients.removeAll { ingredient in
            ingredient == removedIngredient
        }

        removedIngredient.ingredientCategoryId = nil
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
