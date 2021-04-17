import Foundation
import GRDB

/**
 Represents a record of an ingredient batch stored in the local database..
 */
struct IngredientBatchRecord: Identifiable {
    var id: Int64?

    // MARK: - Specification Fields
    /// The id of the ingredient the batch belongs to.
    var ingredientId: Int64?
    /// The expiry date of the batch, or `nil` if it does not expire.
    var expiryDate: Date?
    /// The record of the quantity of the batch.
    var quantity: QuantityRecord
}

extension IngredientBatchRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let ingredientId = Column(CodingKeys.ingredientId)
        static let expiryDate = Column(CodingKeys.expiryDate)
        static let quantity = Column(CodingKeys.quantity)
    }

    static let databaseTableName = "ingredientBatch"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
