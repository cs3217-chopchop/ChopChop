import GRDB

struct Recipe: Equatable {
    var id: Int64?
    var name: String
    var ingredients: [String: Quantity]
    var steps: [String]
}

extension Recipe: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        name = row["name"]
        ingredients = row.prefetchedRows["recipeIngredients"]?.reduce(into: [String: Quantity]()) {
            let ingredient = RecipeIngredientRecord(row: $1)

            $0[ingredient.name] = ingredient.quantity
        } ?? [:]
        steps = row.prefetchedRows["recipeSteps"]?.map { RecipeStepRecord(row: $0).content } ?? []
    }
}