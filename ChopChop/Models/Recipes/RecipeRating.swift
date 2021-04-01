//
//  Rating.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import FirebaseFirestoreSwift

//class RecipeRating {
//    private(set) var ratingId: String // remove this
//    private(set) var name: String
//    private(set) var score: RatingScore
//
//    // remove this ratingId
//    init(ratingId: String, name: String, score: RatingScore) {
//        self.ratingId = ratingId
//        self.name = name
//        self.score = score
//    }
//}

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
