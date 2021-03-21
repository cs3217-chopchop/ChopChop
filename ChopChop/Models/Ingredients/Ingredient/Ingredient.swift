import Foundation
import UIKit
import GRDB

/**
 Represents an ingredient, consisting of batches grouped by expiry date.
 
 Invariants:
 - All quantities are of the same type.
 - Each batch has a unique expiry date.
 */
class Ingredient: FetchableRecord {
    var id: Int64?
    var ingredientCategoryId: Int64?
    let quantityType: BaseQuantityType

    private(set) var name: String
    private(set) var batches: [IngredientBatch]

    init(name: String, type: BaseQuantityType, batches: [IngredientBatch] = []) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.quantityType = type
        self.name = trimmedName

        for batch in batches where batch.quantity.baseType != type {
            throw QuantityError.incompatibleTypes
        }

        self.batches = batches
    }

    required init(row: Row) {
        id = row["id"]
        ingredientCategoryId = row["ingredientCategoryId"]
        quantityType = .count
        name = row["name"]
        batches = row.prefetchedRows["ingredientSets"]?.compactMap {
            let record = IngredientBatchRecord(row: $0)
            guard let quantity = try? Quantity(from: record.quantity) else {
                return nil
            }

            return IngredientBatch(quantity: quantity, expiryDate: record.expiryDate)
        } ?? []
    }

    // TODO: Remove this after quantity types are added into db
    convenience init(name: String, batches: [IngredientBatch]) throws {
        try self.init(name: name, type: .count)
        self.batches = batches
    }

    var image: UIImage? {
        StorageManager().fetchIngredientImage(name: name)
    }

    var notExpiredBatches: [IngredientBatch] {
        batches.filter { batch in
            guard let expiryDate = batch.expiryDate else {
                return true
            }

            return expiryDate >= .today
        }
    }

    var totalQuantity: Double {
        batches
            .map { $0.quantity.baseValue }
            .reduce(0.0, +)
    }

    var totalUsableQuantity: Double {
        notExpiredBatches
            .map { $0.quantity.baseValue }
            .reduce(0.0, +)
    }
}

extension Ingredient {
    /**
     Renames the ingredient with a given name.
     - Throws:
        - `IngredientError.emptyName`: if the given name is empty.
     */
    func rename(_ newName: String) throws {
        // TODO: rename image name as well
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        try StorageManager().renameIngredientImage(from: self.name, to: trimmedName)
        self.name = trimmedName
    }

    /**
     Adds a batch of the ingredient, represented by the given quantity and expiry date.
     - Throws:
        - `QuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    func add(quantity: Quantity, expiryDate: Date?) throws {
        guard self.quantityType == quantity.baseType else {
            throw QuantityError.incompatibleTypes
        }

        var batch: IngredientBatch?

        if let addedDate = expiryDate {
            batch = batches.first(where: { $0.expiryDate == addedDate.startOfDay })
        } else {
            batch = batches.first(where: { $0.expiryDate == nil })
        }

        if let existingBatch = batch {
            try existingBatch.add(quantity)
        } else {
            let addedBatch = IngredientBatch(quantity: quantity, expiryDate: expiryDate?.startOfDay)

            batches.append(addedBatch)
        }
    }

    /**
     Subtracts some quantity from a batch, identified by its expiry date.
     Removes the batch if all its quantity is subtracted.
     - Throws:
        - `QuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `QuantityError.negativeQuantity`:
            if the result is negative.
        - `IngredientError.nonExistentBatch`:
            if a batch with the given expiry date does not exist.
        - `IngredientError.insufficientQuantity`:
            if the batch with the given expiry date does not contain enough quantity.
     */
    func subtract(quantity: Quantity, expiryDate: Date?) throws {
        guard let batch = getBatch(expiryDate: expiryDate) else {
            throw IngredientError.nonExistentBatch
        }

        do {
            try batch.subtract(quantity)
        } catch QuantityError.negativeQuantity {
            throw IngredientError.insufficientQuantity
        }

        if batch.isEmpty {
            removeBatch(expiryDate: expiryDate)
        }
    }

    /**
     Uses up the given quantity, subtracting from the batch with the nearest expiry date to the current date first.
     Removes a batch if all its quantity is subtracted.
     - Throws:
        - `QuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `QuantityError.negativeQuantity`: if the result is negative.
        - `IngredientError.insufficientQuantity`: if all non-expired batches combined do not contain enough quantity.
     */
    func use(quantity: Quantity) throws {
        guard try contains(quantity: quantity) else {
            throw IngredientError.insufficientQuantity
        }

        var subtractedQuantity = quantity
        var usedBatches: [IngredientBatch] = []

        for batch in notExpiredBatches.sorted() {
            do {
                try subtractedQuantity -= batch.quantity
                usedBatches.append(batch)
            } catch QuantityError.negativeQuantity {
                try batch.subtract(subtractedQuantity)
                subtractedQuantity.value = 0
                // swiftlint:disable unneeded_break_in_switch
                break
                // swiftlint:enable unneeded_break_in_switch
            }
        }

        guard subtractedQuantity.value == 0 else {
            throw IngredientError.insufficientQuantity
        }

        removeBatches(usedBatches)
    }

    func contains(quantity: Quantity) throws -> Bool {
        switch (quantityType, quantity.baseType) {
        case (.count, .count), (.mass, .mass), (.mass, .volume), (.volume, .mass), (.volume, .volume):
            return quantity.baseValue <= totalUsableQuantity
        default:
            throw QuantityError.incompatibleTypes
        }
    }

    /**
     Combines this ingredient with another of the same name and quantity type.
     Batches with the same expiry date are merged.
     - Throws:
        - `QuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `QuantityError.negativeQuantity`:
            f any addition result is negative.
        - `IngredientError.differentIngredients`:
            if the given ingredient does not have the same name as this ingredient.
     */
    func combine(with ingredient: Ingredient) throws {
        guard self.name == ingredient.name else {
            throw IngredientError.differentIngredients
        }

        guard self.quantityType == ingredient.quantityType else {
            throw QuantityError.incompatibleTypes
        }

        for batch in ingredient.batches {
            let quantity = batch.quantity
            let expiryDate = batch.expiryDate
            try add(quantity: quantity, expiryDate: expiryDate)
        }
    }
}

// MARK: - Batch operations
extension Ingredient {
    /**
     Returns the batch with the given expiry date, or `nil` if it does not exist.
     */
    func getBatch(expiryDate: Date?) -> IngredientBatch? {
        batches.first { batch in
            batch.expiryDate == expiryDate?.startOfDay
        }
    }

    /**
     Removes the batch identified by the given expiry date.
     If such a batch does not exist, do nothing.
     */
    func removeBatch(expiryDate: Date?) {
        batches.removeAll { batch in
            batch.expiryDate == expiryDate?.startOfDay
        }
    }

    /**
     Removes all batches with expiry dates earlier than the current date.
     */
    func removeExpiredBatches() {
        var removedBatches: [IngredientBatch] = []

        for batch in batches {
            guard let expiryDate = batch.expiryDate else {
                continue
            }

            if expiryDate < .today {
                removedBatches.append(batch)
            }
        }

        removeBatches(removedBatches)
    }

    private func removeBatches(_ removedBatches: [IngredientBatch]) {
        for batch in removedBatches {
            removeBatch(expiryDate: batch.expiryDate)
        }
    }
}

extension Ingredient: Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.quantityType == rhs.quantityType && lhs.name == rhs.name
    }
}

enum IngredientError: Error {
    case emptyName
    case nonExistentBatch
    case insufficientQuantity
    case differentIngredients
}
