import Foundation
import GRDB

struct IngredientSet {
    var id: Int64?
    var ingredientId: Int64?
    var expiryDate: Date
    var quantity: Quantity
}

extension IngredientSet: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let ingredientId = Column(CodingKeys.ingredientId)
        static let expiryDate = Column(CodingKeys.expiryDate)
        static let quantity = Column(CodingKeys.quantity)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
