import Foundation
import GRDB

struct IngredientBatchRecord {
    var id: Int64?
    var ingredientId: Int64?
    var expiryDate: Date?
    var quantity: Quantity
}

extension IngredientBatchRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let ingredientId = Column(CodingKeys.ingredientId)
        static let expiryDate = Column(CodingKeys.expiryDate)
        static let quantity = Column(CodingKeys.quantity)
    }

    static let databaseTableName = "ingredientSet"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
