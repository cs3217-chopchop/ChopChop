import FirebaseFirestoreSwift

/**
 Represents a rating for a published recipe received from other users.
 */
struct RecipeRating {
    // MARK: - Specification Fields
    /// Identifies the firebase document that contains the user who gave the rating.
    private(set) var userId: String
    /// The score given to the recipe.
    private(set) var score: RatingScore
    /**
     Instantiates a recipe rating with the given fields.
     */
    init(userId: String, score: RatingScore) {
        self.userId = userId
        self.score = score
    }
}

// MARK: Codable - Allows encoding to and decoding from firebase document fields
extension RecipeRating: Codable {
}

// MARK: - Firebase document field representation
extension RecipeRating {
    var asDict: [String: Any] {
        ["userId": userId, "score": score.rawValue]
    }
}

// MARK: Equatable
extension RecipeRating: Equatable {
}
