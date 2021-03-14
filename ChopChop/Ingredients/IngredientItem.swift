import Foundation

/**
 Represents some quantity of an ingredient with the same expiry date.
 */
class IngredientItem {
    private(set) var quantity: IngredientQuantity
    private(set) var expiryDate: Date

    init(quantity: IngredientQuantity, expiryDate: Date) {
        self.quantity = quantity
        self.expiryDate = expiryDate
    }

    var isEmpty: Bool {
        quantity.isZero
    }

    func add(_ quantity: IngredientQuantity) {
        do {
            try self.quantity += quantity
        } catch {
            return
        }
    }

    func subtract(_ quantity: IngredientQuantity) {
        do {
            try self.quantity -= quantity
        } catch {
            return
        }
    }

    func subtractAll() {
        subtract(self.quantity)
    }
}

extension IngredientItem: Comparable {
    static func < (lhs: IngredientItem, rhs: IngredientItem) -> Bool {
        lhs.expiryDate < rhs.expiryDate
    }

    static func == (lhs: IngredientItem, rhs: IngredientItem) -> Bool {
        lhs.expiryDate == rhs.expiryDate
    }
}
