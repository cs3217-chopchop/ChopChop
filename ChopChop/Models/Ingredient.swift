import Foundation
import GRDB

struct Ingredient: Equatable {
    var id: Int64?
    var ingredientCategoryId: Int64?
    var name: String
    var batches: [Date?: QuantityRecord] = [:]
}

extension Ingredient: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        ingredientCategoryId = row["ingredientCategoryId"]
        name = row["name"]
        batches = row.prefetchedRows["ingredientBatches"]?.reduce(into: [Date?: QuantityRecord]()) {
            let batch = IngredientBatchRecord(row: $1)

            $0[batch.expiryDate] = batch.quantity
        } ?? [:]
    }
}
