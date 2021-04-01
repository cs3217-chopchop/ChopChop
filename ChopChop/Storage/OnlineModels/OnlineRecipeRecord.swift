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
    @ExplicitNull var difficulty: Difficulty?
    var ingredients: [OnlineIngredientRecord]
    var steps: [String]
    var ratings: [RecipeRating] = []

    func toOnlineRecipe() throws -> OnlineRecipe {
        guard let id = id else {
            throw OnlineRecipeRecordError.missingId
        }
        return try OnlineRecipe(
            id: id,
            userId: creator,
            name: name,
            servings: servings,
            difficulty: difficulty,
            cuisine: cuisine,
            steps: steps,
            ingredients: ingredients.compactMap({ try? $0.toIngredientDetails() }),
            ratings: ratings
        )
    }

}

extension OnlineRecipeRecord: Codable {
}

enum OnlineRecipeRecordError: Error {
    case missingId
}