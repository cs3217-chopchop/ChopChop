//
//  RecipeFormViewModel.swift
//  ChopChop
//
//  Created by Cao Wenjie on 20/3/21.
//
import SwiftUI
import Combine

class RecipeFormViewModel: ObservableObject {
    private var recipe: Recipe?
    @Published var recipeName = ""
    @Published var serving = "" {
        didSet {
            ensureValidServing()
        }
    }
    @Published var recipeCategory = ""
    @Published var difficulty: Difficulty = .veryEasy

    @Published var steps = [String]()
    @Published var ingredients = [RecipeIngredientRowViewModel]()
    @Published var ingredientParsingString = ""
    @Published var instructionParsingString = ""
    var existingRecipeCategories = ["American", "Japanese", "Chinese"]

//    var fieldsAreValid: Bool {
//        return !recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//            && !steps.isEmpty && !ingredients.isEmpty
//    }

    private var recipeCategoriesCancellable: AnyCancellable?

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

        guard let _ = Double(serving) else {
            throw RecipeFormError.invalidServing
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

            if ingredient.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw RecipeFormError.emptyIngredientUnit
            }

            if ingredient.ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw RecipeFormError.emptyIngredientDescription
            }
        }
    }

    func parseData() {
        let parsedIngredients = RecipeParser.parseIngredientString(ingredientString: ingredientParsingString)
        let parsedSteps = RecipeParser.parseInstructions(instructions: instructionParsingString)
        steps.append(contentsOf: parsedSteps)
        instructionParsingString = ""

    }

    func saveRecipe() throws {
        try checkFormValid()
        if recipe == nil {
            try generateRecipe()
        } else {
            try updateRecipe()
        }

        let storage = StorageManager()

        guard var updatedRecipe = recipe else {
            fatalError("Missing recipe.")
        }

        try storage.saveRecipe(&updatedRecipe)
    }

    func generateRecipe() throws {
//        guard let servingSize = Double(serving) else {
//            throw RecipeFormError.invalidServing
//        }
//
//        let recipeStep = try steps.map({ try RecipeStep(content: $0) })
//        let recipeIngredient = try ingredients.map({ try RecipeIngredient(name: $0.ingredientName, quantity: )})
//
//        let newRecipe = Recipe(
//            name: recipeName,
//            servings: servingSize,
//            difficulty: ,
//            steps: recipeStep,
//            ingredients: [RecipeIngredient]
//        )
//
//        recipe = newRecipe
    }

    func updateRecipe() throws {
//        guard let oldRecipe = recipe else {
//            fatalError("Recipe is missing.")
//        }
//
//        try oldRecipe.updateName(recipeName)

    }
}
