//
//  RecipeViewModel.swift
//  ChopChop
//
//  Created by Cao Wenjie on 21/3/21.
//

import SwiftUI
import Combine

class RecipeViewModel: ObservableObject {
    @ObservedObject private(set) var recipe: Recipe
    private(set) var hasError = false
    @Published private(set) var recipeName: String = ""
    @Published private(set) var serving: String = ""
    @Published private(set) var recipeCategory: String = ""
    @Published private(set) var difficulty: Difficulty?
    private var storage = StorageManager()
    @Published private(set) var errorMessage = ""
    @Published private(set) var steps = [String]()
    @Published private(set) var ingredients = [String]()
    private var cancellables = Set<AnyCancellable>()

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
        recipe.$name
            .sink { [weak self] name in
                self?.recipeName = name

            }
            .store(in: &cancellables)
//        recipeName = recipe.name
        serving = recipe.servings.description
        if let categoryId = recipe.recipeCategoryId {
            do {
                recipeCategory = try storage.fetchRecipeCategory(id: categoryId)?.name ?? ""
            } catch {

            }
        }
        recipe.$recipeCategoryId
            .sink { [weak self] category in
                if let categoryId = category {
                    do {
                        self?.recipeCategory = try self?.storage.fetchRecipeCategory(id: categoryId)?.name ?? ""
                    } catch {

                    }
                }
            }
            .store(in: &cancellables)
        recipe.$difficulty
            .sink { [weak self] difficulty in
                self?.difficulty = difficulty

            }
            .store(in: &cancellables)
//        difficulty = recipe.difficulty
        recipe.$steps
            .sink { [weak self] steps in
                self?.steps = steps.map({ $0.content })

            }
            .store(in: &cancellables)
//        steps = recipe.steps.map({ $0.content })
        recipe.$ingredients
            .sink { [weak self] ingredient in
                self?.ingredients = ingredient.map({ $0.description })

            }
            .store(in: &cancellables)
//        ingredients = recipe.ingredients.map({ $0.description })
    }

    func loadRecipe(id: Int64?) {
//        guard let recipeId = id else {
//            fatalError("Recipe does not have a id.")
//        }
//        var fetchedRecipe: Recipe?
//        do {
//            fetchedRecipe = try storage.fetchRecipe(id: recipeId)
//        } catch {
//            hasError = true
//            errorMessage = "Recipe failed to load."
//        }
//        guard let recipe = fetchedRecipe else {
//            fatalError("Recipe not fetched.")
//        }
//        self.recipe = recipe
//        recipeName = recipe.name
//        serving = recipe.servings.description
//        print(serving)
//        if let categoryId = recipe.recipeCategoryId {
//            do {
//                recipeCategory = try storage.fetchCategory(id: categoryId)?.name ?? ""
//            } catch {
//
//            }
//        }
//        difficulty = recipe.difficulty
//        steps = recipe.steps.map({ $0.content })
//        ingredients = recipe.ingredients.map({ $0.description })
    }

}
