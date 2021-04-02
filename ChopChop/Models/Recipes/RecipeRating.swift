import FirebaseFirestoreSwift

struct RecipeRating {
    private(set) var userId: String
    var score: RatingScore

    init(userId: String, score: RatingScore) {
        self.userId = userId
        self.score = score
    }
}

extension RecipeRating: Codable {
}

extension RecipeRating {
    func toDict() -> [String: Any] {
        ["userId": userId, "score": score.rawValue]
    }
}

extension RecipeRating: Equatable {
}
