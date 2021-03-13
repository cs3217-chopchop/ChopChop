import Foundation

protocol IngredientEditable {
    var name: String { get }

    func rename(_ newName: String) throws
    func add<Q: IngredientQuantity>(quantity: Q, expiryDate: Date)
    func subtract<Q: IngredientQuantity>(quantity: Q) throws
    func combine<Q: IngredientQuantity>(with items: [IngredientItem<Q>])
}
