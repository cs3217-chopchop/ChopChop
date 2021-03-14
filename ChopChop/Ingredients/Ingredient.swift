import Foundation

/**
 Represents an ingredient, consisting of batches grouped by expiry date.
 
 Invariants:
 - All quantities are of the same type.
 - Each batch has a unique expiry date.
 */
class Ingredient {
    let quantityType: IngredientQuantityType
    private(set) var name: String
    private(set) var batches: [IngredientBatch]

    init(name: String, type: IngredientQuantityType) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.quantityType = type
        self.name = name
        self.batches = []
    }

    var batchesByExpiryDate: [IngredientBatch] {
        batches.sorted()
    }
}

extension Ingredient {
    /**
     Renames the ingredient with a given name.
     - Throws:
        - `IngredientError.emptyName`: if the given name is empty.
     */
    func rename(_ newName: String) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = newName
    }

    /**
     Adds a batch of the ingredient, represented by the given quantity and expiry date.
     - Throws:
        - `IngredientQuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `IngredientQuantityError.negativeQuantity`: if the result is negative.
     */
    func add(quantity: IngredientQuantity, expiryDate: Date) throws {
        guard self.quantityType == quantity.type else {
            throw IngredientQuantityError.differentQuantityTypes
        }

        let existingBatches = batches.filter { batch in
            batch.expiryDate == expiryDate
        }

        if let existingBatch = existingBatches.first {
            try existingBatch.add(quantity)
        } else {
            let addedBatch = IngredientBatch(quantity: quantity, expiryDate: expiryDate)

            batches.append(addedBatch)
        }
    }

    /**
     Subtracts some quantity from a batch, identified by its expiry date.
     Removes the batch if all its quantity is subtracted.
     - Throws:
        - `IngredientQuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `IngredientQuantityError.negativeQuantity`:
            if the result is negative.
        - `IngredientError.nonExistentBatch`:
            if a batch with the given expiry date does not exist.
        - `IngredientError.insufficientQuantity`:
            if the batch with the given expiry date does not contain enough quantity.
     */
    func subtract(quantity: IngredientQuantity, expiryDate: Date) throws {
        guard self.quantityType == quantity.type else {
            throw IngredientQuantityError.differentQuantityTypes
        }

        guard let batch = getBatch(expiryDate: expiryDate) else {
            throw IngredientError.nonExistentBatch
        }

        guard batch.quantity >= quantity else {
            throw IngredientError.insufficientQuantity
        }

        try batch.subtract(quantity)

        if batch.isEmpty {
            removeBatch(expiryDate: expiryDate)
        }
    }

    /**
     Uses up the given quantity, subtracting from the batch with the nearest expiry date to the current date first.
     Removes a batch if all its quantity is subtracted.
     - Throws:
        - `IngredientQuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `IngredientQuantityError.negativeQuantity`: if the result is negative.
        - `IngredientError.insufficientQuantity`: if all non-expired batches combined do not contain enough quantity.
     */
    func use(quantity: IngredientQuantity) throws {
        guard self.quantityType == quantity.type else {
            throw IngredientQuantityError.differentQuantityTypes
        }

        let currentDate = Date()
        var subtractedQuantity = quantity
        var usedBatches: [IngredientBatch] = []

        for batch in batchesByExpiryDate {
            guard batch.expiryDate > currentDate else {
                continue
            }

            do {
                try subtractedQuantity -= batch.quantity
                usedBatches.append(batch)
            } catch IngredientQuantityError.negativeQuantity {
                try batch.subtract(subtractedQuantity)
                subtractedQuantity.value = 0
                break
            }
        }

        guard subtractedQuantity.value == 0 else {
            throw IngredientError.insufficientQuantity
        }

        removeBatches(usedBatches)
    }

    /**
     Combines this ingredient with another of the same name and quantity type.
     Batches with the same expiry date are merged.
     - Throws:
        - `IngredientQuantityError.differentQuantityTypes`:
            if the given quantity does not have the same type as the ingredient.
        - `IngredientQuantityError.negativeQuantity`:
            f any addition result is negative.
        - `IngredientError.differentIngredients`:
            if the given ingredient does not have the same name as this ingredient.
     */
    func combine(with ingredient: Ingredient) throws {
        guard self.name == ingredient.name else {
            throw IngredientError.differentIngredients
        }

        guard self.quantityType == ingredient.quantityType else {
            throw IngredientQuantityError.differentQuantityTypes
        }

        for batch in ingredient.batches {
            let quantity = batch.quantity
            let expiryDate = batch.expiryDate
            try add(quantity: quantity, expiryDate: expiryDate)
        }
    }

    /**
     Removes the batch identified by the given expiry date.
     If such a batch does not exist, do nothing.
     */
    func removeBatch(expiryDate: Date) {
        batches.removeAll { batch in
            batch.expiryDate == expiryDate
        }
    }

    /**
     Removes all batches with expiry dates earlier than the current date.
     */
    func removeExpiredBatches() {
        let currentDate = Date()
        var removedBatches: [IngredientBatch] = []

        for batch in batches where batch.expiryDate < currentDate {
            removedBatches.append(batch)
        }

        removeBatches(removedBatches)
    }

    private func getBatch(expiryDate: Date) -> IngredientBatch? {
        batches.first { batch in
            batch.expiryDate == expiryDate
        }
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
