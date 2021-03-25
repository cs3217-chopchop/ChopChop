struct RecipeInfo: Identifiable, Equatable {
    var id: Int64?
    var name: String
    var servings: Double
    var difficulty: Difficulty?
}
