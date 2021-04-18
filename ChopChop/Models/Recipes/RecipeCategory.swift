import Foundation
import GRDB

/**
 Represents a collection of recipes.
 */
struct RecipeCategory: Identifiable, Hashable {
    var id: Int64?

    // MARK: - Specification Fields
    /// The name of the category. Cannot be empty.
    let name: String

    /**
     Instantiates a recipe category with the given name.

     - Throws:`RecipeCategoryError.invalidName` if the given name trimmed is empty.
     */
    // swiftlint:disable function_default_parameter_at_end
    init(id: Int64? = nil, name: String) throws {
        self.id = id

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeCategoryError.invalidName
        }

        self.name = trimmedName
    }
    // swiftlint:enable function_default_parameter_at_end
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
