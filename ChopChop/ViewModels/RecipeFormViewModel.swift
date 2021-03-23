//
//  RecipeFormViewModel.swift
//  ChopChop
//
//  Created by Cao Wenjie on 20/3/21.
//
import SwiftUI
import Combine
import GRDB

class RecipeFormViewModel: ObservableObject {

    @Published var hasError: Bool = false
    private var recipeId: Int64?
    private(set) var errorMessage = ""
    private(set) var isEdit = false
    private let storageManager = StorageManager()
    private var recipeCategoryCancellable = Set<AnyCancellable>()
    @Published var recipeName = ""
    @Published var serving = "" {
        didSet {
            ensureValidServing()
        }
    }
    @Published var allRecipeCategories = [RecipeCategory]()
    @Published var recipeCategory = ""
    @Published var difficulty: Difficulty = .veryEasy
    private var storage = StorageManager()
    @Published var steps = [String]()
    @Published var ingredients = [RecipeIngredientRowViewModel]()
    @Published var ingredientParsingString = ""
    @Published var instructionParsingString = ""

    init(recipe: Recipe) {
        recipeId = recipe.id
        recipeName = recipe.name
        serving = recipe.servings.description
        difficulty = recipe.difficulty ?? .veryEasy

        steps = recipe.steps.map({ $0.content })
        ingredients = recipe.ingredients.map({
            RecipeIngredientRowViewModel(
                amount: $0.quantity.value.description,
                unit: $0.quantity.type,
                ingredientName: $0.name
            )
        })
        fetchCategories()
        isEdit = true
    }

    init() {
        fetchCategories()
    }

    private func fetchCategories() {
        storageManager
            .recipeCategoriesPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let self = self else {
                    return
                }
                switch value {
                case .failure:
                    self.allRecipeCategories = []
                case .finished:
                    break
                }
            },
            receiveValue: { [weak self] categories in
                guard let self = self else {
                    return
                }
                self.allRecipeCategories = categories
            })
            .store(in: &recipeCategoryCancellable)
    }

    func ensureValidServing() {
        let filtered = serving.filter { "0123456789".contains($0) }
        if filtered != serving {
            serving = filtered
        }
    }

    func checkFormValid() throws {
        if recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw RecipeFormError.emptyName
        }

        if serving.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw RecipeFormError.emptyServing
        }

        if steps.isEmpty {
            throw RecipeFormError.emptyStep
        }

        for step in steps {
            if step.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw RecipeFormError.emptyStepDescription
            }
        }

        if ingredients.isEmpty {
            throw RecipeFormError.emptyIngredient
        }

        for ingredient in ingredients {
            if ingredient.amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw RecipeFormError.emptyIngredientQuantity
            }

            if ingredient.ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw RecipeFormError.emptyIngredientDescription
            }
        }
    }

    func parseData() {
        let parsedIngredients = RecipeParser.parseIngredientString(ingredientString: ingredientParsingString)
            .map({
                RecipeIngredientRowViewModel(
                    amount: $0.value.value.description,
                    unit: $0.value.type,
                    ingredientName: $0.key
                )
            })
        let parsedSteps = RecipeParser.parseInstructions(instructions: instructionParsingString)
        ingredients.append(contentsOf: parsedIngredients)
        steps.append(contentsOf: parsedSteps)
        instructionParsingString = ""
        ingredientParsingString = ""
    }

    func saveRecipe() -> Bool {
        do {
            try checkFormValid()
            var newRecipe = try generateRecipe()
            try storageManager.saveRecipe(&newRecipe)
            return true
        } catch {
            hasError = true
            setErrorMessage(error: error)
            return false
        }
    }

    private func setErrorMessage(error: Error) {
        switch error {
        case RecipeFormError.emptyName:
            errorMessage = RecipeFormError.emptyName.rawValue
        case RecipeFormError.emptyServing:
            errorMessage = RecipeFormError.emptyServing.rawValue
        case RecipeFormError.invalidServing:
            errorMessage = RecipeFormError.invalidServing.rawValue
        case RecipeFormError.emptyStep:
            errorMessage = RecipeFormError.emptyStep.rawValue
        case RecipeFormError.emptyStepDescription:
            errorMessage = RecipeFormError.emptyStepDescription.rawValue
        case RecipeFormError.emptyIngredient:
            errorMessage = RecipeFormError.emptyIngredient.rawValue
        case RecipeFormError.emptyIngredientQuantity:
            errorMessage = RecipeFormError.emptyIngredientQuantity.rawValue
        case RecipeFormError.invalidIngredientQuantity:
            errorMessage = RecipeFormError.invalidIngredientQuantity.rawValue
        case RecipeFormError.emptyIngredientDescription:
            errorMessage = RecipeFormError.emptyIngredientDescription.rawValue
        case DatabaseError.SQLITE_CONSTRAINT:
            errorMessage = "You already have a recipe with the same name."
        default:
            errorMessage = error.localizedDescription
        }
    }

    private func getRecipeCategoryId() -> Int64? {
        if recipeCategory.isEmpty {
            return nil
        }

        for category in allRecipeCategories where category.name == recipeCategory {
            return category.id
        }

        return nil
    }

    func generateRecipe() throws -> Recipe {
        guard let servingSize = Double(serving) else {
            throw RecipeFormError.invalidServing
        }

        let recipeStep = try steps.map({ try RecipeStep(content: $0) })
        let recipeIngredient = try ingredients.map({
            try $0.convertToIngredient()
        })
        let recipeCategoryId = getRecipeCategoryId()

        let newRecipe = try Recipe(
            name: recipeName,
            servings: servingSize,
            difficulty: difficulty,
            steps: recipeStep,
            ingredients: recipeIngredient
        )
        newRecipe.id = recipeId
        newRecipe.recipeCategoryId = recipeCategoryId

        return newRecipe
    }
}
