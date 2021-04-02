//
//  OnlineRecipe.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import FirebaseFirestoreSwift

//class OnlineRecipe {
//    @DocumentID private(set) var id: String?
//    private(set) var userId: String
//    private(set) var ratings: [RecipeRating]
//    private(set) var recipeDetails: OnlineRecipeDetails
//
//    init(id: String?, userId: String, ratings: [RecipeRating], recipeDetails: OnlineRecipeDetails) {
//        self.id = id
//        self.userId = userId
//        self.ratings = ratings
//        self.recipeDetails = recipeDetails
//    }
//}
class OnlineRecipe: Identifiable {
    private(set) var id: String
    private(set) var userId: String

    private(set) var name: String
    private(set) var servings: Double
    private(set) var cuisine: String?
    private(set) var difficulty: Difficulty?
    private(set) var steps: [String]
    private(set) var ingredients: [RecipeIngredient]
    private(set) var ratings: [RecipeRating]

    init(id: String, userId: String, name: String, servings: Double, difficulty: Difficulty?, cuisine: String?,
         steps: [String], ingredients: [RecipeIngredient], ratings: [RecipeRating]) throws {
        self.id = id
        self.userId = userId
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }
        self.name = trimmedName

        guard servings > 0 else {
            throw RecipeError.invalidServings
        }
        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.steps = steps
        self.ingredients = ingredients
        self.ratings = ratings
    }
}

extension OnlineRecipe {
    func toRecipe() throws -> Recipe {
        try Recipe(
            name: name,
            onlineId: id,
            servings: servings,
            difficulty: difficulty,
            steps: try steps.map({ try RecipeStep(content: $0) }),
            ingredients: ingredients
        )
    }
}
