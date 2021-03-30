//
//  UserRating.swift
//  ChopChop
//
//  Created by Cao Wenjie on 29/3/21.
//

import FirebaseFirestoreSwift

struct UserRating {
    private(set) var recipeOnlineId: String
    private(set) var score: RatingScore
}

extension UserRating: Codable {
}
