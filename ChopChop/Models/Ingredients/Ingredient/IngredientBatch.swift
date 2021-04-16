import Foundation
import SwiftUI

/**
 Represents some quantity of an ingredient with the same expiry date.
 */
class IngredientBatch: ObservableObject {
    // MARK: - Specification Fields
    /// The quantity of the batch.
    @Published private(set) var quantity: Quantity
    /// The expiry date of the batch, or `nil` if the batch does not expire.
    let expiryDate: Date?

    init(quantity: Quantity, expiryDate: Date? = nil) {
        self.quantity = quantity
        self.expiryDate = expiryDate?.startOfDay
    }

    var isEmpty: Bool {
        quantity.value == 0
    }

    /**
     Adds the given quantity into the batch.

     - Throws:
        - `QuantityError.incompatibleTypes`: if the type of the quantity is not compatible with that of the batch.
     */
    func add(_ quantity: Quantity) throws {
        try self.quantity += quantity
    }

    /**
     Subtracts the given quantity from the batch.

     - Throws:
        - `QuantityError.incompatibleTypes`: if the type of the quantity is not compatible with that of the batch.
        - `QuantityError.negativeQuantity`: if the given quantity is greater than that contained in the batch.
     */
    func subtract(_ quantity: Quantity) throws {
        try self.quantity -= quantity
    }
}

extension IngredientBatch: Comparable {
    /**
     Compares two batches based on their expiry dates.

     A batch is smaller if it does not expire or if its expiry date is earlier than another batch.
     */
    static func < (lhs: IngredientBatch, rhs: IngredientBatch) -> Bool {
        guard let rightDate = rhs.expiryDate else {
            return true
        }

        guard let leftDate = lhs.expiryDate else {
            return false
        }

        return leftDate < rightDate
    }

    /**
     Compares two batches based on their quantities and expiry dates.

     Two batches are equal if they have the same expiry date and quantity.
     */
    static func == (lhs: IngredientBatch, rhs: IngredientBatch) -> Bool {
        lhs.expiryDate == rhs.expiryDate && lhs.quantity == rhs.quantity
    }
}
