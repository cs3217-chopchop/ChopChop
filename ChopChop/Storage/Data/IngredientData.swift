struct IngredientData: Codable {
    let name: String
    let category: String
    let type: QuantityType
    let quantities: [QuantityRecord]
}
