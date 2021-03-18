import GRDB
import Foundation

/**
 Represents some quantity of an ingredient.
 */
class RecipeIngredient {
    var id: Int64?
    private(set) var name: String
    private(set) var quantity: Quantity

    init(name: String, quantity: Quantity) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        // additional check that RecipeIngredient Quantity cannot be 0
        guard quantity.value > 0 else {
            throw RecipeIngredientError.invalidQuantity
        }

        self.name = trimmedName
        self.quantity = quantity
    }

    func add(_ quantity: Quantity) throws {
        try self.quantity += quantity
    }

    func subtract(_ quantity: Quantity) throws {
        guard try (self.quantity - quantity).value > 0 else {
            // will become zero
            throw RecipeIngredientError.invalidQuantity
        }
        try self.quantity -= quantity
    }

    func scale(_ factor: Double) throws {
        guard factor > 0 else {
            throw RecipeIngredientError.invalidQuantity
        }
        try self.quantity *= factor
    }

    func rename(_ name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = trimmedName
    }

    func updateQuantity(_ quantity: Quantity) throws {
        guard quantity.value > 0 else {
            throw RecipeIngredientError.invalidQuantity
        }
        self.quantity = quantity
    }

}

extension RecipeIngredient: Equatable {
    static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        lhs.quantity == rhs.quantity && lhs.name == rhs.name
    }
}

extension RecipeIngredient: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = try? RecipeIngredient(name: name, quantity: quantity) else {
            fatalError("Cannot copy RecipeIngredient")
        }
        return copy
    }
}

enum RecipeIngredientError: Error {
    case invalidQuantity
}
