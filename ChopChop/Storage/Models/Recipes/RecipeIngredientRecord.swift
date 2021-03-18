import GRDB

struct RecipeIngredientRecord {
    var id: Int64?
    var recipeId: Int64?
    var name: String
    var quantity: QuantityRecord
}

extension RecipeIngredientRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeId = Column(CodingKeys.recipeId)
        static let name = Column(CodingKeys.name)
        static let quantity = Column(CodingKeys.quantity)
    }

    static let databaseTableName = "recipeIngredient"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
