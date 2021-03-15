import Foundation
import GRDB

struct Ingredient: Equatable {
    var id: Int64?
    var ingredientCategoryId: Int64?
    var name: String
    var batches: [Date?: Quantity] = [:]
}

extension Ingredient: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        ingredientCategoryId = row["ingredientCategoryId"]
        name = row["name"]
        batches = row.prefetchedRows["ingredientSets"]?.reduce(into: [Date?: Quantity]()) {
            let batch = IngredientBatchRecord(row: $1)

            $0[batch.expiryDate] = batch.quantity
        } ?? [:]
    }
}
