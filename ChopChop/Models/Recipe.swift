import GRDB

struct Recipe: Equatable {
    var id: Int64?
    var recipeCategoryId: Int64?
    var name: String
    var ingredients: [String: Quantity] = [:]
    var steps: [String] = []
}

extension Recipe: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        recipeCategoryId = row["recipeCategoryId"]
        name = row["name"]
        ingredients = row.prefetchedRows["recipeIngredients"]?.reduce(into: [String: Quantity]()) {
            let ingredient = RecipeIngredientRecord(row: $1)

            $0[ingredient.name] = ingredient.quantity
        } ?? [:]
        steps = row.prefetchedRows["recipeSteps"]?.map { RecipeStepRecord(row: $0).content } ?? []
    }
}

//extension Recipe: Decodable {
//    private enum CodingKeys: CodingKey {
//        case name, ingredients, instructions
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.name = try container.decode(String.self, forKey: .name)
//        let instructions = try container.decode(String.self, forKey: .instructions)
//        self.steps = RecipeParser.fromJsonStringToSteps(jsonInstructions: instructions)
//        let ingredients = try container.decode([String].self, forKey: .ingredients)
//        self.ingredients = RecipeParser.fromJsonStringArrayToIngredientDict(jsonIngredients: ingredients)
//    }
//
//}
