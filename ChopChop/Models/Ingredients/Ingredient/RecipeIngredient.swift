import GRDB
import Foundation

/**
 Represents some quantity of an ingredient.
 */
class RecipeIngredient: Identifiable {
    var id: Int64?
    private(set) var name: String
    private(set) var quantity: Quantity

    init(name: String, quantity: Quantity) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = trimmedName
        self.quantity = quantity
    }

    func add(_ quantity: Quantity) throws {
        try self.quantity += quantity
    }

    func subtract(_ quantity: Quantity) throws {
        try self.quantity -= quantity
    }

    func scale(_ factor: Double) throws {
        try self.quantity *= factor
    }

    func rename(_ name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = trimmedName
    }

    func updateQuantity(_ quantity: Quantity) {
        self.quantity = quantity
    }

}

extension RecipeIngredient: Equatable {
    static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        lhs.quantity == rhs.quantity && lhs.name == rhs.name
    }
}

extension RecipeIngredient: CustomStringConvertible {
    var description: String {
        "\(quantity.description) \(name)"
    }

}

extension RecipeIngredient: Hashable {

}

extension RecipeIngredient: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = try? RecipeIngredient(name: name, quantity: quantity) else {
            fatalError("Cannot copy RecipeIngredient")
        }
        return copy
    }
}
