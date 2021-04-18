import Foundation
import UIKit
import GRDB

/**
 Represents an ingredient, consisting of batches grouped by expiry date.
 
 Representation Invariants:
 - All quantities have non negative value.
 - All quantities are of the same type.
 - Each batch has a unique expiry date.
 */
struct Ingredient {
    var id: Int64?

    // MARK: - Specification Fields
    /// The name of the ingredient. Cannot be empty.
    let name: String
    /// The type of the quantities of the ingredient.
    let quantityType: QuantityType
    /// The batches of the ingredient, grouped by expiry date.
    var batches: [IngredientBatch]
    /// The category which the ingredient belongs to, or `nil` if the ingredient does not belong to any category.
    let category: IngredientCategory?

    /**
     Instantiates an ingredient with the given name, type, batches and category.
     
     - Throws:
        - `IngredientError.emptyName` if the given name trimmed is empty.
        - ` QuantityError.incompatibleTypes` if the types of the given batches do not match the given type.
     */
    // swiftlint:disable function_default_parameter_at_end
    init(id: Int64? = nil,
         name: String,
         type: QuantityType,
         batches: [IngredientBatch] = [],
         category: IngredientCategory? = nil) throws {

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        for batch in batches where batch.quantity.type != type {
            throw QuantityError.incompatibleTypes
        }

        self.id = id
        self.name = trimmedName
        self.quantityType = type
        self.batches = batches
        self.category = category
    }
    // swiftlint:enable function_default_parameter_at_end

    // MARK: - Quantity Operations

    /**
     Adds a batch of the ingredient, represented by the given quantity and expiry date.

     - Throws:
        - `QuantityError.incompatibleTypes`:
            if the type of the given quantity is not compatible with the ingredient type.
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    mutating func add(quantity: Quantity, expiryDate: Date?) throws {
        guard self.quantityType == quantity.type else {
            throw QuantityError.incompatibleTypes
        }

        if let batchId = batches.firstIndex(where: { $0.expiryDate == expiryDate?.startOfDay }) {
            var batch = batches[batchId]
            try batch.add(quantity)
            batches[batchId] = batch
        } else {
            let addedBatch = IngredientBatch(quantity: quantity, expiryDate: expiryDate?.startOfDay)
            batches.append(addedBatch)
        }
    }

    /**
     Subtracts some quantity from a batch, identified by its expiry date.
     Removes the batch if all its quantity is subtracted.

     - Throws:
        - `IngredientError.nonExistentBatch`:
            if a batch with the given expiry date does not exist.
        - `IngredientError.insufficientQuantity`:
            if the batch with the given expiry date does not contain enough quantity.
     */
    mutating func subtract(quantity: Quantity, expiryDate: Date?) throws {
        guard let batchId = batches.firstIndex(where: { $0.expiryDate == expiryDate?.startOfDay }) else {
            throw IngredientError.nonExistentBatch
        }

        do {
            var batch = batches[batchId]
            try batch.subtract(quantity)

            if batch.isEmpty {
                removeBatch(expiryDate: expiryDate)
            } else {
                batches[batchId] = batch
            }
        } catch QuantityError.negativeQuantity {
            throw IngredientError.insufficientQuantity
        }
    }

    /**
     Uses up the given quantity, subtracting from the batch with the nearest expiry date to the current date first.
     Removes a batch if all its quantity is subtracted.

     - Throws:`IngredientError.insufficientQuantity`:
        if all non-expired batches combined do not contain enough quantity.
     */
    mutating func use(quantity: Quantity) throws {
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
                try subtract(quantity: subtractedQuantity, expiryDate: batch.expiryDate)
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

    /**
     Checks if the ingredient contains more than or equal to the given quantity.

     - Throws:`QuantityError.incompatibleTypes`:
        if the type of the given quantity is not compatible with the ingredient type.
     */
    func contains(quantity: Quantity) throws -> Bool {
        switch (quantityType, quantity.type) {
        case (.count, .count), (.mass, .mass), (.mass, .volume), (.volume, .mass), (.volume, .volume):
            return quantity.baseValue <= totalUsableQuantity
        default:
            throw QuantityError.incompatibleTypes
        }
    }

    // MARK: - Batch Operations

    /**
     Returns the batch with the given expiry date, or `nil` if such a batch does not exist.
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
    mutating func removeBatch(expiryDate: Date?) {
        batches.removeAll { batch in
            batch.expiryDate == expiryDate?.startOfDay
        }
    }

    /**
     Removes all batches with expiry dates earlier than the current date.
     */
    mutating func removeExpiredBatches() {
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

    /**
     Removes all batches from the ingredient.
     */
    mutating func removeAllBatches() {
        batches = []
    }

    private mutating func removeBatches(_ removedBatches: [IngredientBatch]) {
        for batch in removedBatches {
            removeBatch(expiryDate: batch.expiryDate)
        }
    }

    // MARK: - Quantity Descriptions

    /**
     String description of the total quantity of the ingredient.
     */
    var totalQuantityDescription: String {
        getQuantityDescription(value: totalQuantity)
    }

    /**
     String description of the total not expired quantity of the ingredient.
     */
    var totalUsableQuantityDescription: String {
        getQuantityDescription(value: totalUsableQuantity)
    }

    private var notExpiredBatches: [IngredientBatch] {
        batches.filter { batch in
            guard let expiryDate = batch.expiryDate else {
                return true
            }

            return expiryDate >= .today
        }
    }

    private var totalQuantity: Double {
        batches
            .map { $0.quantity.baseValue }
            .reduce(0.0, +)
    }

    private var totalUsableQuantity: Double {
        notExpiredBatches
            .map { $0.quantity.baseValue }
            .reduce(0.0, +)
    }

    private func getQuantityDescription(value: Double) -> String {
        switch quantityType {
        case .count:
            let description = try? Quantity(.count, value: value).description
            return description ?? "None"
        case .mass:
            let description = try? Quantity(.mass(.baseUnit), value: value).description
            return description ?? "None"
        case .volume:
            let description = try? Quantity(.volume(.baseUnit), value: value).description
            return description ?? "None"
        }
    }
}

extension Ingredient: FetchableRecord {
    init(row: Row) {
        id = row[IngredientRecord.Columns.id]
        category = row["ingredientCategory"]
        quantityType = row[IngredientRecord.Columns.quantityType]
        name = row[IngredientRecord.Columns.name]
        batches = row.prefetchedRows["ingredientBatches"]?.compactMap {
            let record = IngredientBatchRecord(row: $0)
            guard let quantity = try? Quantity(from: record.quantity) else {
                return nil
            }

            return IngredientBatch(quantity: quantity, expiryDate: record.expiryDate)
        } ?? []
    }
}

extension Ingredient: Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.quantityType == rhs.quantityType && lhs.name == rhs.name
    }
}

enum IngredientError: String, Error {
    case emptyName = "Ingredient name cannot be empty."
    case nonExistentBatch = "Ingredient batch is non-existent."
    case insufficientQuantity = "Ingredient has insufficient quantity."
    case differentIngredients = "Ingredients are different."
}
