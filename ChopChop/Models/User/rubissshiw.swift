class OnlineRecipe: Identifiable {
    private(set) var id: String
    private(set) var userId: String

    private(set) var name: String
    private(set) var servings: Double
    private(set) var cuisine: String
    private(set) var difficulty: Difficulty?
    private(set) var steps: [String]
    private(set) var ingredients: [RecipeIngredient]
    private(set) var ratings: [RecipeRating]

    init(id: String, userId: String, name: String, servings: Double, difficulty: Difficulty?, cuisine: String,
         steps: [String], ingredients: [RecipeIngredient], ratings: [RecipeRating]) throws {
        self.id = id
        self.userId = userId
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }
        self.name = trimmedName

        guard servings > 0 else {
            throw RecipeError.invalidServings
        }
        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.steps = steps
        self.ingredients = ingredients
        self.ratings = ratings
    }
}

struct RecipeRating {
    private(set) var userId: String
    var score: RatingScore

    init(userId: String, score: RatingScore) {
        self.userId = userId
        self.score = score
    }
}

enum RatingScore: Int {
    case poor = 1, fair, adequate, great, excellent
}

extension RatingScore: CustomStringConvertible {
    var description: String {
        switch self {
        case .poor:
            return "Poor"
        case .fair:
            return "Fair"
        case .adequate:
            return "Adequate"
        case .great:
            return "Great"
        case .excellent:
            return "Excellent"
        }
    }
}
