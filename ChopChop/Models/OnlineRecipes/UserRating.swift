import FirebaseFirestoreSwift

/**
 Represents a rating given to a published recipe from a particular user.
 */
struct UserRating {
    // MARK: - Specification Fields
    /// Identifies the firebase document that contains the recipe the rating is given to.
    private(set) var recipeId: String
    /// The score given by the user.
    private(set) var score: RatingScore

    /**
     Instantiates a user rating with the given fields.
     */
    init(recipeOnlineId: String, score: RatingScore) {
        self.recipeId = recipeOnlineId
        self.score = score
    }
}

// MARK: Codable - Allows encoding to and decoding from firebase document fields
extension UserRating: Codable {
}

// MARK: - Firebase document field representation
extension UserRating {
    var asDict: [String: Any] {
        ["recipeId": recipeId, "score": score.rawValue]
    }
}
