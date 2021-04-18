import GRDB
import Combine
import Foundation

/**
 Represents a collection of ingredients.
 */
struct IngredientCategory: Identifiable, Hashable {
    var id: Int64?

    // MARK: - Specification Fields
    /// The name of the category. Cannot be empty.
    let name: String

    /**
     Instantiates an ingredient category with the given name.

     - Throws:`IngredientCategoryError.invalidName` if the given name trimmed is empty.
     */
    init(name: String, id: Int64? = nil) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientCategoryError.invalidName
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
    case invalidName

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Category name should not be empty."
        }
    }
}
