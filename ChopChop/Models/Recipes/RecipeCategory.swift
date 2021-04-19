import Foundation
import GRDB

/**
 Represents a collection of recipes.
 
 Representation Invariants:
 - Name is not empty.
 */
struct RecipeCategory: Identifiable, Hashable {
    // MARK: - Specification Fields
    /// Identifies which row in the recipe category table in local storage this category represents.
    var id: Int64?
    /// The name of the category. Cannot be empty.
    let name: String

    /**
     Instantiates a recipe category with the given name.

     - Throws:`RecipeCategoryError.invalidName` if the given name trimmed is empty.
     */
    init(id: Int64? = nil, name: String) throws {
        self.id = id

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeCategoryError.invalidName
        }

        self.name = trimmedName
    }
}

extension RecipeCategory: FetchableRecord {
    init(row: Row) {
        id = row[RecipeCategoryRecord.Columns.id]
        name = row[RecipeCategoryRecord.Columns.name]
    }
}

enum RecipeCategoryError: LocalizedError {
    case invalidName

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Category name should not be empty."
        }
    }
}
