import Foundation

/**
 Represents a batch of an ingredient.
 A batch contains some quantity of an ingredient with the same expiry date.
 */
class IngredientBatch {
    private(set) var quantity: IngredientQuantity
    private(set) var expiryDate: Date

    init(quantity: IngredientQuantity, expiryDate: Date) {
        self.quantity = quantity
        self.expiryDate = expiryDate
    }

    var isEmpty: Bool {
        quantity.value == 0
    }

    func add(_ quantity: IngredientQuantity) throws {
        try self.quantity += quantity
    }

    func subtract(_ quantity: IngredientQuantity) throws {
        try self.quantity -= quantity
    }
}

/**
 Two batches are compared based on their expiry dates.
 Two batches are equal if they have the same expiry date and quantity
 */
extension IngredientBatch: Comparable {
    static func < (lhs: IngredientBatch, rhs: IngredientBatch) -> Bool {
        lhs.expiryDate < rhs.expiryDate
    }

    static func == (lhs: IngredientBatch, rhs: IngredientBatch) -> Bool {
        lhs.expiryDate == rhs.expiryDate && lhs.quantity == rhs.quantity
    }
}
