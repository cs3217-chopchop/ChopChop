//
//  Rating.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import FirebaseFirestoreSwift

struct RecipeRating {
    private(set) var userId: String
    private(set) var score: RatingScore
}

extension RecipeRating: Codable {
}
