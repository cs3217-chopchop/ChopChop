import Foundation

protocol IngredientEditable {
    associatedtype Quantity: IngredientQuantity

    var name: String { get }
    var items: [IngredientItem<Quantity>] { get }

    func rename(_ newName: String) throws
    func add(item: IngredientItem<Quantity>)
    func subtract(quantity: Quantity) throws
    func combine(with ingredient: Self) throws
}
