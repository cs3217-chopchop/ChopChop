import Combine
import GRDB
import UIKit

/**
 Represents the view model for a view of a form for adding or editing a recipe.
 */
class RecipeFormViewModel: ObservableObject {
    /// The recipe edited by the form, or `nil` if the form adds a new recipe.
    private let recipe: Recipe?
    /// The original image of the recipe edited by the form, or a default `UIImage` if the form adds a new recipe.
    private let originalImage: UIImage

    /// A collection of recipe categories.
    @Published var categories: [RecipeCategory] = []

    /// Form fields
    @Published var name: String
    @Published var category: RecipeCategory?
    @Published var servings: String
    @Published var difficulty: Difficulty?
    @Published var ingredients: [RecipeIngredientRowViewModel]
    @Published var stepGraph: RecipeStepGraph
    @Published var image: UIImage

    /// Form errors
    @Published var formErrors: [String: [String]] = [:]

    /// Display flags
    @Published var isParsingIngredients = false
    @Published var isParsingSteps = false
    @Published var ingredientsToBeParsed = ""
    @Published var stepsToBeParsed = ""
    @Published var stepGraphIsPresented = false
    @Published var ingredientActionSheetIsPresented = false
    @Published var stepActionSheetIsPresented = false

    /// Alert fields
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    /// Image picker fields
    @Published var imagePickerIsPresented = false
    var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(recipe: Recipe? = nil, category: RecipeCategory? = nil) {
        self.recipe = recipe

        self.name = recipe?.name ?? ""
        self.category = recipe?.category ?? category

        if let servings = recipe?.servings {
            self.servings = servings.removeZerosFromEnd()
        } else {
            self.servings = ""
        }

        self.difficulty = recipe?.difficulty
        self.ingredients = recipe?.ingredients.map {
            RecipeIngredientRowViewModel(name: $0.name,
                                         quantity: $0.quantity.value.removeZerosFromEnd(),
                                         unit: $0.quantity.unit)

        } ?? []
        self.stepGraph = recipe?.stepGraph.copy() ?? RecipeStepGraph()

        if let id = recipe?.id, let image = storageManager.fetchRecipeImage(name: String(id)) {
            self.image = image
            self.originalImage = image
        } else {
            self.image = UIImage()
            self.originalImage = UIImage()
        }

        categoriesPublisher
            .sink { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
    }

    var isEditing: Bool {
        recipe != nil
    }

    /**
     Updates the servings of the recipe that is being updated in the form.
     */
    func setServings(_ servings: String) {
        self.servings = String(servings.filter { "0123456789.".contains($0) })
            .components(separatedBy: ".")
            .prefix(2)
            .joined(separator: ".")
    }

    /**
     Parses the ingredient text in the text field to a collection of ingredients,
     overwriting or appending to the current collection depending on the given flag.
     */
    func parseIngredients(shouldOverwrite: Bool = false) {
        let parsedIngredients = RecipeParser.parseIngredientText(ingredientText: ingredientsToBeParsed)
            .map({
                RecipeIngredientRowViewModel(
                    name: $0.key,
                    quantity: $0.value.value.description,
                    unit: $0.value.unit
                )
            })

        if shouldOverwrite {
            ingredients = parsedIngredients
        } else {
            ingredients.append(contentsOf: parsedIngredients)
        }

        isParsingIngredients = false
        ingredientsToBeParsed = ""
    }

    /**
     Parses the steps text in the text field to a collection of steps.
     */
    func parseSteps() {
        let parsedSteps = RecipeParser.parseInstructions(instructions: stepsToBeParsed)
        let nodes: [RecipeStepNode] = parsedSteps.compactMap { content in
            guard let step = try? RecipeStep(content) else {
                return nil
            }

            return RecipeStepNode(step)
        }

        var edges: [Edge<RecipeStepNode>] = []

        for index in nodes.indices.dropLast() {
            guard let edge = Edge(source: nodes[index], destination: nodes[index + 1]) else {
                continue
            }

            edges.append(edge)
        }

        stepGraph = (try? RecipeStepGraph(nodes: nodes, edges: edges)) ?? RecipeStepGraph()
        isParsingSteps = false
        stepsToBeParsed = ""
        stepGraphIsPresented = true
    }

    /**
     Saves the recipe to local storage.
     */
    func saveRecipe() -> Bool {
        guard validateRecipe() else {
            return false
        }

        do {
            guard let servings = Double(servings) else {
                throw RecipeError.invalidServings
            }

            var isImageUploaded = false

            if let id = recipe?.id,
               storageManager.fetchRecipeImage(name: String(id))?.pngData() == image.pngData(),
               recipe?.isImageUploaded == true {
                // image no change or image is still null
                isImageUploaded = true
            }

            var updatedRecipe = try Recipe(id: recipe?.id,
                                           onlineId: recipe?.onlineId,
                                           isImageUploaded: isImageUploaded,
                                           parentOnlineRecipeId: recipe?.parentOnlineRecipeId,
                                           name: name,
                                           category: category,
                                           servings: servings,
                                           difficulty: difficulty,
                                           ingredients: ingredients.map { try $0.convertToIngredient() },
                                           stepGraph: stepGraph)

            try storageManager.saveRecipe(&updatedRecipe)

            if let id = updatedRecipe.id {
                if image == UIImage() {
                    storageManager.deleteRecipeImage(name: String(id))
                } else {
                    try storageManager.saveRecipeImage(image, name: String(id))
                }
            }

            return true
        } catch {
            if let message = (error as? LocalizedError)?.errorDescription {
                alertTitle = "Error"
                alertMessage = message
            } else {
                alertTitle = "Database error"
                alertMessage = "\(error)"
            }

            alertIsPresented = true

            return false
        }
    }

    private func validateRecipe() -> Bool {
        formErrors = [:]

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            formErrors["name", default: []].append(RecipeError.invalidName.errorDescription ?? "")
        }

        if Double(servings) ?? 0 <= 0 {
            formErrors["servings", default: []].append(RecipeError.invalidServings.errorDescription ?? "")
        }

        if ingredients.count > Set(ingredients.map { $0.name }).count {
            formErrors["ingredients", default: []].append(RecipeError.duplicateIngredients.errorDescription ?? "")
        }

        if !ingredients.allSatisfy({ ingredient in
            guard let quantity = Double(ingredient.quantity) else {
                return false
            }

            return quantity >= 0
        }) {
            formErrors["ingredients", default: []].append(QuantityError.invalidQuantity.errorDescription ?? "")
        }

        if !ingredients.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            formErrors["ingredients", default: []].append(RecipeIngredientError.invalidName.errorDescription ?? "")
        }

        if !formErrors.isEmpty {
            alertTitle = "Error"
            alertMessage = "Recipe could not be added due to errors."
            alertIsPresented = true
        }

        return formErrors.isEmpty
    }

    private var categoriesPublisher: AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
