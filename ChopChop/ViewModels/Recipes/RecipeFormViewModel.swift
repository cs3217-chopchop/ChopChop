import Combine
import GRDB
import UIKit

class RecipeFormViewModel: ObservableObject {
    @Published var categories: [RecipeCategory] = []

    @Published var name: String
    @Published var category: RecipeCategory?
    @Published var servings: String
    @Published var difficulty: Difficulty?
    @Published var ingredients: [RecipeIngredientRowViewModel]
    @Published var stepGraph: RecipeStepGraph
    @Published var image: UIImage

    @Published var isParsingIngredients = false
    @Published var isParsingSteps = false
    @Published var ingredientsToBeParsed = ""
    @Published var stepsToBeParsed = ""
    @Published var stepGraphIsPresented = false
    @Published var ingredientActionSheetIsPresented = false
    @Published var stepActionSheetIsPresented = false

    @Published var imagePickerIsPresented = false
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    @Published var formErrors: [String: [String]] = [:]

    var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    var isEditing: Bool {
        recipe != nil
    }

    private let storageManager = StorageManager()
    private var categoriesCancellable: AnyCancellable?
    private let recipe: Recipe?

    init(recipe: Recipe? = nil) {
        self.recipe = recipe

        self.name = recipe?.name ?? ""
        self.category = recipe?.category

        if let servings = recipe?.servings {
            self.servings = String(servings)
        } else {
            self.servings = ""
        }

        self.difficulty = recipe?.difficulty
        self.ingredients = recipe?.ingredients.map {
            RecipeIngredientRowViewModel(name: $0.name,
                                         quantity: $0.quantity.value.description,
                                         unit: $0.quantity.unit)

        } ?? []
        self.stepGraph = recipe?.stepGraph.copy() ?? RecipeStepGraph()

        if let id = recipe?.id {
            self.image = storageManager.fetchRecipeImage(name: String(id)) ?? UIImage()
        } else {
            self.image = UIImage()
        }

        categoriesCancellable = categoriesPublisher()
            .sink { [weak self] categories in
                self?.categories = categories
            }
    }

    func setServings(_ servings: String) {
        self.servings = String(servings.filter { "0123456789.".contains($0) })
            .components(separatedBy: ".")
            .prefix(2)
            .joined(separator: ".")
    }

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

    func saveRecipe() -> Bool {
        guard validateRecipe() else {
            return false
        }

        do {
            guard let servings = Double(servings) else {
                throw RecipeError.invalidServings
            }

            var updatedRecipe = try Recipe(id: recipe?.id,
                                           onlineId: recipe?.onlineId,
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
        var hasErrors = false
        formErrors = [:]

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            formErrors["name", default: []].append(RecipeError.invalidName.errorDescription ?? "")
            hasErrors = true
        }

        if Double(servings) ?? 0 <= 0 {
            formErrors["servings", default: []].append(RecipeError.invalidServings.errorDescription ?? "")
            hasErrors = true
        }

        if ingredients.count > Set(ingredients.map { $0.name }).count {
            formErrors["ingredients", default: []].append(RecipeError.duplicateIngredients.errorDescription ?? "")
            hasErrors = true
        }

        if !ingredients.allSatisfy({ ingredient in
            guard let quantity = Double(ingredient.quantity) else {
                return false
            }

            return quantity >= 0
        }) {
            formErrors["ingredients", default: []].append(QuantityError.invalidQuantity.errorDescription ?? "")
            hasErrors = true
        }

        if !ingredients.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            formErrors["ingredients", default: []].append(RecipeIngredientError.invalidName.errorDescription ?? "")
            hasErrors = true
        }

        if hasErrors {
            alertTitle = "Error"
            alertMessage = "Recipe could not be added due to errors."
            alertIsPresented = true
        }

        return !hasErrors
    }

    private func categoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
