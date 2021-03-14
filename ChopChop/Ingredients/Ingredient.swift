import Foundation

/**
 Represents a collection of same type quantities of the same ingredient, grouped by expiry date.
 */
class Ingredient<Quantity: IngredientQuantity> {
    private(set) var name: String
    private(set) var items: [IngredientItem<Quantity>]

    init(name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = name
        self.items = []
    }

    var itemsByExpiryDate: [IngredientItem<Quantity>] {
        items.sorted()
    }
}

extension Ingredient: IngredientEditable {
    typealias Quantity = Quantity

    func rename(_ newName: String) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = newName
    }

    func add(item: IngredientItem<Quantity>) {
        let addedQuantity = item.quantity
        let expiryDate = item.expiryDate

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

    func subtract(quantity: Quantity) throws {
        let currentDate = Date()
        var subtractedQuantity = quantity
        var usedItems: [IngredientItem<Quantity>] = []

        for item in itemsByExpiryDate {
            guard item.expiryDate > currentDate else {
                continue
            }

            do {
                try subtractedQuantity -= item.quantity
                usedItems.append(item)
            } catch {
                item.subtract(subtractedQuantity)
                subtractedQuantity = .zero
                break
            }
        }

        guard subtractedQuantity == .zero else {
            throw IngredientError.insufficientIngredients
        }

        let remainingItems = items.filter { item in
            !usedItems.contains(item)
        }

        self.items = remainingItems
    }

    func combine(with ingredient: Ingredient) throws {
        guard self.name == ingredient.name else {
            throw IngredientError.differentIngredients
        }

        for item in ingredient.items {
            add(item: item)
        }
    }
}

enum IngredientError: Error {
    case emptyName
    case insufficientIngredients
    case differentIngredients
    case differentQuantityType
}
