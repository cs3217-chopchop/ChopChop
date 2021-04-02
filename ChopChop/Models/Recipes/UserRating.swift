//
//  UserRating.swift
//  ChopChop
//
//  Created by Cao Wenjie on 29/3/21.
//

import FirebaseFirestoreSwift

final class UserRating {

    private(set) var recipeId: String
    private(set) var score: RatingScore

    init(recipeOnlineId: String, score: RatingScore) {
        self.recipeId = recipeOnlineId
        self.score = score
    }
}

extension UserRating: Codable {
}

extension UserRating {
    func toDict() -> [String: Any] {
        ["recipeId": recipeId, "score": score.rawValue]
    }
}
