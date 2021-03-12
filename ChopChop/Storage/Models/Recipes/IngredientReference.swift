import GRDB

struct IngredientReference {
    var id: Int64?
    var recipeId: Int64?
    var name: String
    var quantity: Quantity
}

extension IngredientReference: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeId = Column(CodingKeys.recipeId)
        static let name = Column(CodingKeys.name)
        static let quantity = Column(CodingKeys.quantity)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
