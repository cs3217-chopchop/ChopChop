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

    private var existingRecipe: Recipe?
    private var recipeId: Int64?
    private let storageManager = StorageManager()
    private var recipeCategoryCancellable = Set<AnyCancellable>()

    private(set) var errorMessage = ""
    private(set) var isEdit = false

    var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    @Published var hasError: Bool = false
    @Published var isShowingPhotoLibrary = false
    @Published var image = UIImage()
    @Published var recipeName = ""
    @Published var serving = ""
    @Published var allRecipeCategories = [RecipeCategory]()
    @Published var recipeCategory = ""
    @Published var difficulty: String = ""
    @Published var steps = [String]()
    @Published var ingredients = [RecipeIngredientRowViewModel]()
    @Published var ingredientParsingString = ""
    @Published var instructionParsingString = ""

    init(recipe: Recipe) {
        existingRecipe = recipe
        recipeId = recipe.id
        recipeName = recipe.name
        serving = recipe.servings.description
        difficulty = recipe.difficulty?.description ?? ""
        steps = recipe.steps.map({ $0.content })
        ingredients = recipe.ingredients.map({
            RecipeIngredientRowViewModel(
                amount: $0.quantity.value.description,
                unit: $0.quantity.type,
                ingredientName: $0.name
            )
        })
        image = storageManager.fetchRecipeImage(name: recipe.name) ?? UIImage()
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
                switch value {
                case .failure:
                    self?.allRecipeCategories = []
                    self?.recipeCategory = ""
                case .finished:
                    break
                }
            },
            receiveValue: { [weak self] categories in
                self?.allRecipeCategories = categories
                if let categoryId = self?.existingRecipe?.recipeCategoryId {
                    self?.recipeCategory = categories.first(where: { $0.id == categoryId })?.name ?? ""
                }
            })
            .store(in: &recipeCategoryCancellable)
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
            var newRecipe = try generateRecipe()
            if isEdit {
                guard var recipe = existingRecipe else {
                    fatalError("Missing existing recipe.")
                }
                recipe.updateRecipe(newRecipe)
                try storageManager.saveRecipe(&recipe)
            } else {
                try storageManager.saveRecipe(&newRecipe)
            }
            if image != UIImage() {
                try storageManager.saveRecipeImage(image, name: recipeName)
            }
            return true
        } catch {
            hasError = true
            setErrorMessage(error: error)
            return false
        }
    }

    private func setErrorMessage(error: Error) {
        switch error {
        case RecipeError.invalidName:
            errorMessage = RecipeError.invalidName.rawValue
        case RecipeError.invalidServings:
            errorMessage = RecipeError.invalidServings.rawValue
        case RecipeFormError.invalidServing:
            errorMessage = RecipeFormError.invalidServing.rawValue
        case RecipeStepError.invalidContent:
            errorMessage = RecipeStepError.invalidContent.rawValue
        case RecipeFormError.invalidIngredientQuantity:
            errorMessage = RecipeFormError.invalidIngredientQuantity.rawValue
        case IngredientError.emptyName:
            errorMessage = IngredientError.emptyName.rawValue
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
        let recipeDifficulty = difficulty.isEmpty ? nil : try Difficulty(description: difficulty)

        let newRecipe = try Recipe(
            name: recipeName,
            servings: servingSize,
            difficulty: recipeDifficulty,
            steps: recipeStep,
            ingredients: recipeIngredient
        )
        newRecipe.id = recipeId
        newRecipe.recipeCategoryId = recipeCategoryId
        return newRecipe
    }
}

enum RecipeFormError: String, Error {
    case invalidIngredientQuantity = "Recipe ingredient amount is not a valid number."
    case invalidServing = "Recipe serving is empty or not a valid number."
}
