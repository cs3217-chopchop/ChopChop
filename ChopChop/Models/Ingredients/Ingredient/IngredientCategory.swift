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
    let name: String

    init(name: String, id: Int64? = nil) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientCategoryError.emptyName
        }

        self.id = id
        self.name = trimmedName
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
