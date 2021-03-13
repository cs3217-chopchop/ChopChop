import Foundation
import GRDB

struct Ingredient: Equatable {
    var id: Int64?
    var name: String
    var sets: [Date?: Quantity]
}

extension Ingredient: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        name = row["name"]
        sets = row.prefetchedRows["ingredientSets"]?.reduce(into: [Date?: Quantity]()) {
            let set = IngredientSetRecord(row: $1)

            $0[set.expiryDate] = set.quantity
        } ?? [:]
    }
}
