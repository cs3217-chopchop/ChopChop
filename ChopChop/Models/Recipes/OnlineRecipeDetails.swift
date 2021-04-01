//
//  OnlineRecipeDetails.swift
//  ChopChop
//
//  Created by Cao Wenjie on 1/4/21.
//

class OnlineRecipeDetails {
    private(set) var name: String
    private(set) var servings: Double
    private(set) var cuisine: String
    private(set) var difficulty: Difficulty?
    private(set) var steps: [String]
    private(set) var ingredients: [OnlineRecipeIngredient]

    init(name: String, servings: Double, difficulty: Difficulty?, cuisine: String,
         steps: [String], ingredients: [OnlineRecipeIngredient]) throws {
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
    }
}
