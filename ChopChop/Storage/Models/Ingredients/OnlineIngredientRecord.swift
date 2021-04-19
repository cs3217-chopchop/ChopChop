import FirebaseFirestoreSwift

/**
 Represents a record of an ingredient stored in the online database.
 */
struct OnlineIngredientRecord {

    // MARK: - Specification Fields
    /// The name of the ingredient.
    var name: String
    /// The record of the quantity of the ingredient.
    var quantity: QuantityRecord
}

extension OnlineIngredientRecord: Codable {
}

extension OnlineIngredientRecord {
    var asDict: [String: Any] {
        ["name": name, "quantity": quantity.asDict]
    }
}

extension OnlineIngredientRecord: Equatable {
}
