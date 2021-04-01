//
//  RecipeRatingRecord.swift
//  ChopChop
//
//  Created by Cao Wenjie on 1/4/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct RecipeRatingRecord {
    private(set) var userId: String
    private(set) var score: RatingScore
}

extension RecipeRatingRecord: Codable {
}
