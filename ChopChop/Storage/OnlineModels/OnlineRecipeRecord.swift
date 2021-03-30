//
//  OnlineRecipeRecord.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import FirebaseFirestoreSwift

struct OnlineRecipeRecord {
    @DocumentID var id: String?
    var name: String
    var creator: String
    var servings: Double
    var cuisine: String
    var difficulty: Difficulty?
    var ingredients: [OnlineIngredientRecord]
    var steps: [String]
    var ratings: [RecipeRating] = []
}

extension OnlineRecipeRecord: Codable {
}
