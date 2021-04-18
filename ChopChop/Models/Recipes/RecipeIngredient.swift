import Foundation

/**
 Represents some quantity of an ingredient used to make a recipe.
 */
struct RecipeIngredient: Equatable {

    // MARK: - Specification Fields
    /// The name of the ingredient. Cannot be empty.
    let name: String
    /// The quantity of the ingredient.
    let quantity: Quantity

    /**
     Instantiates a recipe ingredient with the given name and quantity.

     - Throws:`RecipeIngredientError.invalidName` if the given name trimmed is empty.
     */
    init(name: String, quantity: Quantity) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw RecipeIngredientError.invalidName
        }

        self.name = trimmedName
        self.quantity = quantity
    }

    init(from record: OnlineIngredientRecord) throws {
        try self.init(name: record.name, quantity: Quantity(from: record.quantity))
    }
}

extension RecipeIngredient: CustomStringConvertible {
    var description: String {
        "\(quantity.description) \(name)"
    }
}

enum RecipeIngredientError: LocalizedError {
    case invalidName

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Ingredient name should not be empty."
        }
    }
}
