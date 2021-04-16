import GRDB
import Combine
import Foundation

/**
 Represents a collection of ingredients.
 
 Representation Invariants:
 - The `ingredientCategoryId` of all ingredients contained in this category is the same as the category's `id`.
 */
struct IngredientCategory: Identifiable, Hashable {
    var id: Int64?

    // MARK: - Specification Fields
    /// The name of the category. Cannot be empty.
    private(set) var name: String

    init(name: String, id: Int64? = nil) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientCategoryError.emptyName
        }

        self.id = id
        self.name = trimmedName
    }

    /**
     Renames the ingredient category with a given name.
     - Throws:
        - `IngredientCategoryError.emptyName`: if the given name is empty.
     */
    mutating func rename(_ newName: String) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientCategoryError.emptyName
        }

        name = trimmedName
    }

    /**
     Adds the given ingredient into the category.
     If the category contains an existing ingredient with the same name and quantity type,
     combines the given ingredient instead.
     */
    func add(_ addedIngredient: Ingredient) throws {
        let storageManager = StorageManager()
        var ingredientInfos: [IngredientInfo] = []

        _ = storageManager.ingredientsPublisher(query: "", categoryIds: [id])
            .sink(receiveCompletion: { _ in }, receiveValue: { ingredients in
                ingredientInfos = ingredients
            })

        guard let existingIngredientInfo = ingredientInfos.first(where: { $0.name == addedIngredient.name }),
              let existingIngredientId = existingIngredientInfo.id,
              let existingIngredient = try storageManager.fetchIngredient(id: existingIngredientId) else {
            addedIngredient.ingredientCategoryId = id
            return
        }

        try existingIngredient.combine(with: addedIngredient)
        if let addedId = addedIngredient.id {
            try storageManager.deleteIngredients(ids: [addedId])
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
}

extension IngredientCategory: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        name = row["name"]
    }
}

enum IngredientCategoryError: LocalizedError {
    case emptyName

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Category name cannot be empty"
        }
    }
}
