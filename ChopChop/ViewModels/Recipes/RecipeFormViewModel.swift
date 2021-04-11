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

    @Published var imagePickerIsPresented = false
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

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
                                         type: $0.quantity.type)

        } ?? []
        self.stepGraph = recipe?.stepGraph.copy() ?? RecipeStepGraph()

        if let name = recipe?.name {
            self.image = storageManager.fetchRecipeImage(name: name) ?? UIImage()
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

    func parseIngredients() {
        let parsedIngredients = RecipeParser.parseIngredientString(ingredientString: ingredientsToBeParsed)
            .map({
                RecipeIngredientRowViewModel(
                    name: $0.key,
                    quantity: $0.value.value.description,
                    type: $0.value.type
                )
            })

        ingredients.append(contentsOf: parsedIngredients)
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
        do {
            guard let servings = Double(servings) else {
                throw QuantityError.invalidQuantity
            }

            if image != UIImage() {
                try storageManager.saveRecipeImage(image, name: name)

                // Delete old image if name changed (if it exists)
                if let oldName = recipe?.name, name != oldName {
                    storageManager.deleteRecipeImage(name: oldName)
                }
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

    private func categoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
