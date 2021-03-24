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

    private var storage = StorageManager()
    private var cancellables = Set<AnyCancellable>()
    private let storageManager = StorageManager()

    private(set) var hasError = false

    @Published var isShowingForm = false
    @Published var isShowingPhotoLibrary = false
    @Published private(set) var recipeName: String = ""
    @Published private(set) var serving: Double = 1
    @Published private(set) var recipeCategory: String = ""
    @Published private(set) var difficulty: Difficulty?
    @Published var image: UIImage
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
        image = storageManager.fetchRecipeImage(name: recipe.name) ?? UIImage()
        recipe.$name
            .sink { [weak self] name in
                self?.recipeName = name
            }
            .store(in: &cancellables)

        serving = recipe.servings
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

        recipe.$steps
            .sink { [weak self] steps in
                self?.steps = steps.map({ $0.content })

            }
            .store(in: &cancellables)

        recipe.$ingredients
            .sink { [weak self] ingredient in
                self?.ingredients = ingredient.map({ $0.description })

            }
            .store(in: &cancellables)
    }

}
