//
//  RecipeFormViewModel.swift
//  ChopChop
//
//  Created by Cao Wenjie on 20/3/21.
//
import SwiftUI
import Combine

class RecipeFormViewModel: ObservableObject {
//    private var recipe: Recipe?
    @Published var hasError: Bool = false
    var errorMessage = ""
    var isEdit = false
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
//        storage = StorageManager()
        recipeName = recipe.name
        serving = recipe.servings.description
        difficulty = recipe.difficulty ?? .veryEasy

//        recipeCategoryCancellable = storageManager
//            .recipeCategoriesOrderedByNamePublisher()
//            .sink { [weak self] categories in
//                self?.allRecipeCategories = categories
//            }
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

    private func recipeCategoryPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesOrderedByNamePublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }

    private func fetchCategories() {
        storageManager
            .recipeCategoriesOrderedByNamePublisher()
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

    func saveRecipe() throws {
        do {
            try checkFormValid()
            var newRecipe = try generateRecipe()
            try storageManager.saveRecipe(&newRecipe)
        } catch RecipeFormError.emptyName {
            hasError = true
            errorMessage = RecipeFormError.emptyName.rawValue
        } catch RecipeFormError.emptyServing {
            hasError = true
            errorMessage = RecipeFormError.emptyServing.rawValue
        } catch RecipeFormError.invalidServing {
            hasError = true
            errorMessage = RecipeFormError.invalidServing.rawValue
        } catch RecipeFormError.emptyStep {
            hasError = true
            errorMessage = RecipeFormError.emptyStep.rawValue
        } catch RecipeFormError.emptyStepDescription {
            hasError = true
            errorMessage = RecipeFormError.emptyStepDescription.rawValue
        } catch RecipeFormError.emptyIngredient {
            hasError = true
            errorMessage = RecipeFormError.emptyIngredient.rawValue
        } catch RecipeFormError.emptyIngredientQuantity {
            hasError = true
            errorMessage = RecipeFormError.emptyIngredientQuantity.rawValue
        } catch RecipeFormError.emptyIngredientDescription {
            hasError = true
            errorMessage = RecipeFormError.emptyIngredientDescription.rawValue
        }
    }

    func generateRecipe() throws -> Recipe {
        guard let servingSize = Double(serving) else {
            throw RecipeFormError.invalidServing
        }

        let recipeStep = try steps.map({ try RecipeStep(content: $0) })
        let recipeIngredient = try ingredients.map({
            try RecipeIngredient(
                name: $0.ingredientName,
                quantity: Quantity($0.unit, value: Double($0.amount) ?? 0)
            )})

        let newRecipe = try Recipe(
            name: recipeName,
            servings: servingSize,
            difficulty: difficulty,
            steps: recipeStep,
            ingredients: recipeIngredient
        )

        return newRecipe
    }
}
