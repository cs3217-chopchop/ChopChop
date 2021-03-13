import Foundation

/**
 Represents a collection of quantities of the same ingredient, grouped by expiry date.
 */
class Ingredient<Quantity: IngredientQuantity> {
    private(set) var name: String
    private(set) var items: [IngredientItem<Quantity>]

    init(name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw Error.emptyName
        }

        self.name = name
        self.items = []
    }

    var itemsByExpiryDate: [IngredientItem<Quantity>] {
        items.sorted()
    }

    enum Error: Swift.Error {
        case emptyName
        case insufficientIngredients
    }
}

extension Ingredient: IngredientEditable {
    func rename(_ newName: String) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw Error.emptyName
        }

        self.name = newName
    }

    func add<Q: IngredientQuantity>(quantity: Q, expiryDate: Date) {
        guard let addedQuantity = quantity as? Quantity else {
            return
        }

        let existingItems = items.filter { item in
            item.expiryDate == expiryDate
        }

        if let existingItem = existingItems.first {
            existingItem.add(addedQuantity)
        } else {
            let addedItem = IngredientItem<Quantity>(quantity: addedQuantity, expiryDate: expiryDate)

            items.append(addedItem)
        }
    }

    func subtract<Q: IngredientQuantity>(quantity: Q) throws {
        guard var subtractedQuantity = quantity as? Quantity else {
            return
        }

        let currentDate = Date()

        for item in itemsByExpiryDate {
            guard item.expiryDate > currentDate else {
                continue
            }

            do {
                try subtractedQuantity -= item.quantity
                item.subtractAll()
            } catch IngredientQuantityError.negativeQuantity {
                item.subtract(subtractedQuantity)
                break
            }
        }

        let remainingItems = items.filter { item in
            !item.isEmpty
        }

        self.items = remainingItems
    }

    func combine<Q: IngredientQuantity>(with items: [IngredientItem<Q>]) {
        for item in items {
            add(quantity: item.quantity, expiryDate: item.expiryDate)
        }
    }
}
