//
//  RecipeViewModel.swift
//  ChopChop
//
//  Created by Cao Wenjie on 21/3/21.
//

import SwiftUI

class RecipeViewModel: ObservableObject {
    private(set) var recipe: Recipe
    private(set) var hasError = false
    @Published private(set) var recipeName: String
    @Published private(set) var serving: String
    @Published private(set) var recipeCategory: String = ""
    @Published private(set) var difficulty: Difficulty?
    private var storage = StorageManager()
    @Published private(set) var errorMessage = ""
    @Published private(set) var steps = [String]()
    @Published private(set) var ingredients = [String]()

    init(id: Int64?) {

        guard let recipeId = id else {
            fatalError("Recipe does not have a id.")
        }
        var fetchedRecipe: Recipe?
        do {
            fetchedRecipe = try storage.fetchRecipe(id: recipeId)
        } catch {
            hasError = true
            errorMessage = "Recipe failed to load."
        }
        guard let recipe = fetchedRecipe else {
            fatalError("Recipe not fetched.")
        }
        self.recipe = recipe
        recipeName = recipe.name
        serving = recipe.servings.description
        if let categoryId = recipe.recipeCategoryId {
            do {
                recipeCategory = try storage.fetchCategory(id: categoryId)?.name ?? ""
            } catch {

            }
        }
        difficulty = recipe.difficulty
        steps = recipe.steps.map({ $0.content })
        ingredients = recipe.ingredients.map({ $0.description })
    }

    func loadRecipe(id: Int64?) {
        guard let recipeId = id else {
            fatalError("Recipe does not have a id.")
        }
        var fetchedRecipe: Recipe?
        do {
            fetchedRecipe = try storage.fetchRecipe(id: recipeId)
        } catch {
            hasError = true
            errorMessage = "Recipe failed to load."
        }
        guard let recipe = fetchedRecipe else {
            fatalError("Recipe not fetched.")
        }
        self.recipe = recipe
        recipeName = recipe.name
        serving = recipe.servings.description
        recipeCategory = recipe.recipeCategoryId?.description ?? "" //to change
        difficulty = recipe.difficulty
        steps = recipe.steps.map({ $0.content })
        ingredients = recipe.ingredients.map({ $0.description })
    }

}
