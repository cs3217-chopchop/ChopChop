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

    init(recipe: Recipe) {
        self.recipe = recipe
        image = storageManager.fetchRecipeImage(name: recipe.name) ?? UIImage()

        bindName()
        bindServing()
        bindRecipeCategory()
        bindDifficulty()
        bindSteps()
        bindInstructions()
    }

    private func bindName() {
        recipe.$name
            .sink { [weak self] name in
                self?.recipeName = name
            }
            .store(in: &cancellables)
    }

    private func bindServing() {
        recipe.$servings
            .sink { [weak self] serving in
                self?.serving = serving
            }
            .store(in: &cancellables)
    }

    private func bindDifficulty() {
        recipe.$difficulty
            .sink { [weak self] difficulty in
                self?.difficulty = difficulty

            }
            .store(in: &cancellables)
    }

    private func bindSteps() {
        recipe.$steps
            .sink { [weak self] steps in
                self?.steps = steps.map({ $0.content })

            }
            .store(in: &cancellables)
    }

    private func bindInstructions() {
        recipe.$ingredients
            .sink { [weak self] ingredient in
                self?.ingredients = ingredient.map({ $0.description })

            }
            .store(in: &cancellables)
    }

    private func bindRecipeCategory() {
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
    }

}
