import GRDB
import Combine

/**
 Represents a collection of ingredients grouped under a category.
 
 Invariants:
 - The `ingredientCategoryId` of all ingredients contained in this category is the same as the category's `id`.
 */
struct IngredientCategory {
    var id: Int64?
    private(set) var name: String

    init(name: String, id: Int64? = nil) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.id = id
        self.name = trimmedName
    }

    /**
     Renames the ingredient category with a given name.
     - Throws:
        - `IngredientError.emptyName`: if the given name is empty.
     */
    mutating func rename(_ newName: String) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        name = trimmedName
    }

    /**
     Adds the given ingredient into the category.
     If the category contains an existing ingredient with the same name and quantity type,
     combines the given ingredient instead.
     */
    func add(_ addedIngredient: inout Ingredient) throws {
        let storageManager = StorageManager()

        // TODO: Replace this with storage manager call to get ingredients in this category
        let ingredients: [Ingredient] = []

        guard var existingIngredient = ingredients.first(where: { $0 == addedIngredient }) else {
            addedIngredient.ingredientCategoryId = id
            try storageManager.saveIngredient(&addedIngredient)
            return
        }

        do {
            try existingIngredient.combine(with: addedIngredient)
            try storageManager.saveIngredient(&existingIngredient)
            if let addedId = addedIngredient.id {
                try storageManager.deleteIngredients(ids: [addedId])
            }
        } catch {
            return
        }
    }

    /**
     Removes the given ingredient from the category.
     If such an ingredient does not exist, do nothing.
     */
    func remove(_ removedIngredient: inout Ingredient) throws {
        let storageManager = StorageManager()

        removedIngredient.ingredientCategoryId = nil
        try storageManager.saveIngredient(&removedIngredient)
    }

    /**
     Returns the ingredient with the given name and quantity type,
     or `nil` if it does not exist in the category.
     */
    func getIngredient(name: String, type: BaseQuantityType) -> Ingredient? {
        let storageManager = StorageManager()

        // TODO: Replace this with storage manager call to get ingredients in this category
        let ingredients: [Ingredient] = []

        return ingredients.first { ingredient in
            ingredient.name == name && ingredient.quantityType == type
        }
    }
}

extension IngredientCategory: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        name = row["name"]
    }
}
