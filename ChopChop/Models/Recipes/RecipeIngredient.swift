import Foundation

struct RecipeIngredient: Equatable {
    let name: String
    let quantity: Quantity

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
