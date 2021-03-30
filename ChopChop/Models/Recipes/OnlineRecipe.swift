//
//  OnlineRecipe.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import FirebaseFirestoreSwift

final class OnlineRecipe {
    @DocumentID private(set) var id: String?
    private(set) var userId: String
    private(set) var ratings: [RecipeRating]
    private(set) var recipeDetails: Recipe
    
    init(id: String?, userId: String, ratings: [RecipeRating], recipeDetails: Recipe) {
        self.id = id
        self.userId = userId
        self.ratings = ratings
        self.recipeDetails = recipeDetails
    }
}
