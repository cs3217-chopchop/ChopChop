import Foundation
import GRDB

struct RecipeCategory: Identifiable, Hashable {
    var id: Int64?
    let name: String

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
