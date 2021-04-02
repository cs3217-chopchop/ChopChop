//
//  OnlineRecipeRecord.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import Foundation
import FirebaseFirestoreSwift

struct OnlineRecipeRecord {
    @DocumentID var id: String?
    var name: String
    var creator: String
    var servings: Double
    @ExplicitNull var cuisine: String?
    @ExplicitNull var difficulty: Difficulty?
    var ingredients: [OnlineIngredientRecord]
    var steps: [String]
    var ratings: [RecipeRating] = []
    @ServerTimestamp var created: Date?

    func toOnlineRecipe() throws -> OnlineRecipe {
        guard let id = id else {
            throw OnlineRecipeRecordError.missingId
        }

        guard let createdDate = created else {
            throw OnlineRecipeRecordError.missingCreatedDate
        }
        return try OnlineRecipe(
            id: id,
            userId: creator,
            name: name,
            servings: servings,
            difficulty: difficulty,
            cuisine: cuisine,
            steps: steps,
            ingredients: ingredients.compactMap({ try? $0.toRecipeIngredient() }),
            ratings: ratings,
            created: createdDate
        )
    }

}

extension OnlineRecipeRecord: Equatable {
}

extension OnlineRecipeRecord: Codable {
}

enum OnlineRecipeRecordError: Error {
    case missingId, missingCreatedDate
}
