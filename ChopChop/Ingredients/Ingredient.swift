import Foundation

/**
 Represents an ingredient, consisting of batches grouped by expiry date.
 
 Invariants:
 - All quantities are of the same type.
 - Each batch has a unique expiry date.
 */
class Ingredient {
    let type: IngredientQuantityType
    private(set) var name: String
    private(set) var batches: [IngredientBatch]

    init(name: String, type: IngredientQuantityType) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.type = type
        self.name = name
        self.batches = []
    }

    var batchesByExpiryDate: [IngredientBatch] {
        batches.sorted()
    }
}

extension Ingredient {
    func rename(_ newName: String) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = newName
    }

    func add(quantity: IngredientQuantity, expiryDate: Date) throws {
        guard self.type == quantity.type else {
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

    func subtract(quantity: IngredientQuantity, expiryDate: Date) throws {
        guard self.type == quantity.type else {
            throw IngredientQuantityError.differentQuantityTypes
        }

        guard let batch = getBatch(expiryDate: expiryDate) else {
            throw IngredientError.nonExistentBatch
        }

        guard batch.quantity >= quantity else {
            throw IngredientError.insufficientIngredients
        }

        try batch.subtract(quantity)

        if batch.isEmpty {
            removeBatch(expiryDate: expiryDate)
        }
    }

    func use(quantity: IngredientQuantity) throws {
        guard self.type == quantity.type else {
            throw IngredientQuantityError.differentQuantityTypes
        }

        let currentDate = Date()
        var subtractedQuantity = quantity
        var usedBatches: [IngredientBatch] = []

        for batch in BatchesByExpiryDate {
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
            throw IngredientError.insufficientIngredients
        }

        removeBatches(usedBatches)
    }

    func combine(with ingredient: Ingredient) throws {
        guard self.name == ingredient.name else {
            throw IngredientError.differentIngredients
        }

        guard self.type == ingredient.type else {
            throw IngredientQuantityError.differentQuantityTypes
        }

        for batch in ingredient.batches {
            let quantity = batch.quantity
            let expiryDate = batch.expiryDate
            try add(quantity: quantity, expiryDate: expiryDate)
        }
    }

    func removeBatch(expiryDate: Date) {
        batches.removeAll { batch in
            batch.expiryDate == expiryDate
        }
    }

    func removeExpiredBatches() {
        let currentDate = Date()
        var removedBatches: [IngredientBatch] = []

        for batch in batches {
            if batch.expiryDate < currentDate {
                removedBatches.append(batch)
            }
        }

        removeBatches(removedBatches)
    }

    private func getBatch(expiryDate: Date) -> IngredientBatch? {
        batches.filter { batch in
            batch.expiryDate == expiryDate
        }
        .first
    }

    private func removeBatches(_ removedBatches: [IngredientBatch]) {
        for batch in removedBatches {
            removeBatch(expiryDate: batch.expiryDate)
        }
    }
}

extension Ingredient: Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.type == rhs.type
            && lhs.name == rhs.name
    }
}

enum IngredientError: Error {
    case emptyName
    case nonExistentBatch
    case insufficientIngredients
    case differentIngredients
}
