struct RecipeData: Codable {
    let name: String
    let category: String
    let ingredients: [RecipeIngredientData]
    let steps: [String]
}

extension RecipeData {
    struct RecipeIngredientData: Codable {
        let name: String
        let quantity: QuantityRecord
    }
}
