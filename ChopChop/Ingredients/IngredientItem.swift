import Foundation

/**
 Represents some quantity of an ingredient with the same expiry date.
 */
class IngredientItem<Quantity: IngredientQuantity> {
    private(set) var quantity: Quantity
    private(set) var expiryDate: Date

    init(quantity: Quantity, expiryDate: Date) {
        self.quantity = quantity
        self.expiryDate = expiryDate
    }

    func add(_ quantity: Quantity) {
        do {
            try self.quantity += quantity
        } catch {
            return
        }
    }

    func subtract(_ quantity: Quantity) {
        do {
            try self.quantity -= quantity
        } catch {
            return
        }
    }
}

extension IngredientItem: Comparable {
    static func < (lhs: IngredientItem<Quantity>, rhs: IngredientItem<Quantity>) -> Bool {
        lhs.expiryDate < rhs.expiryDate
    }

    static func == (lhs: IngredientItem<Quantity>, rhs: IngredientItem<Quantity>) -> Bool {
        lhs.expiryDate == rhs.expiryDate
    }
}
