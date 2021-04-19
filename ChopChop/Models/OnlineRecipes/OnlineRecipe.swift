import Foundation

/**
 Represents an online recipe, which is one that has been published online for other users to view.
 
 Representation Invariants:
 - Name is not empty.
 - Servings is a positive number.
 - Ingredients do not contain duplicates, identified by name.
 - Step graph is valid.
 */

struct OnlineRecipe: Identifiable, CachableEntity {
    // MARK: - Specification Fields
    /// Identifies the firebase document that contains this recipe.
    /// This id is autogenerated by firebase when the recipe is first added to firebase.
    let id: String
    /// Identifies the firebase document that contains the user who created this recipe.
    let creatorId: String
    /// Identifies the firebase document that contains the recipe that this recipe is adapted from.
    /// This Id exists if this recipe was previously downloaded from another recipe, and is `nil` otherwise
    let parentOnlineRecipeId: String?
    /// The name of the recipe. Cannot be empty.
    let name: String
    /// The number of people this recipe is designed to feed. Must be more than 0.
    let servings: Double
    /// The cuisine description of this recipe.
    /// Is `nil` if unspecified.
    let cuisine: String?
    /// A measure of the difficulty to make the recipe.
    /// Is `nil` if there is no associated difficulty.
    let difficulty: Difficulty?
    /// The instructions to make the recipe, modeled as a graph.
    let stepGraph: RecipeStepGraph
    /// The ingredients required to make the recipe.
    let ingredients: [RecipeIngredient]
    /// The ratings given by other users to this recipe.
    let ratings: [RecipeRating]
    /// The time of adding the recipe to firebase.
    let createdAt: Date
    /// The time where this recipe is last updated on firebase.
    let updatedAt: Date

    /**
     Instantiates an online recipe with the given parameters.
     - Throws:
        - `RecipeError.invalidName` if the given name trimmed is empty.
        - `RecipeError.invalidServings` if the given serving size is non positive.
        - `RecipeError.duplicateIngredients` if the given ingredients contain duplicates.
     */
    // swiftlint:disable function_default_parameter_at_end
    init(id: String, userId: String, parentOnlineRecipeId: String? = nil, name: String, servings: Double,
         difficulty: Difficulty?, cuisine: String?, stepGraph: RecipeStepGraph,
         ingredients: [RecipeIngredient], ratings: [RecipeRating],
         createdAt: Date, updatedAt: Date) throws {
        self.id = id
        self.creatorId = userId
        self.parentOnlineRecipeId = parentOnlineRecipeId
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }
        self.name = trimmedName

        guard servings > 0 else {
            throw RecipeError.invalidServings
        }

        guard ingredients.count == Set(ingredients.map { $0.name }).count else {
            throw RecipeError.duplicateIngredients
        }

        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.stepGraph = stepGraph
        self.ingredients = ingredients
        self.ratings = ratings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
// MARK: Firebase-dependent initialization
extension OnlineRecipe {

    /**
     Instantiates an online recipe from the firebase storage models, OnlineRecipeRecord and OnlineRecipeInfoRecord.
     - Throws:
        - `OnlineRecipeRecordError.missingId` if the OnlineRecipeRecord does not have an Id.
        - `OnlineRecipeRecordError.missingCreatedDate` if the OnlineRecipeInfoRecord does not have a published date.
        - `OnlineRecipeRecordError.missingUpdatedDate` if the OnlineRecipeInfoRecord does not have a last updated date.
     */
    init(from record: OnlineRecipeRecord, info: OnlineRecipeInfoRecord) throws {
        guard let id = record.id else {
            throw OnlineRecipeRecordError.missingId
        }

        guard let createdDate = info.createdAt else {
            throw OnlineRecipeRecordError.missingCreatedDate
        }

        guard let updatedDate = info.updatedAt else {
            throw OnlineRecipeRecordError.missingUpdatedDate
        }

        var uuidToRecipeStepNodeMap = [String: RecipeStepNode]()
        record.steps.forEach({
            let step = try? RecipeStep($0.content)
            guard let recipeStep = step else {
                return
            }
            uuidToRecipeStepNodeMap[$0.id] = RecipeStepNode(recipeStep)
        })

        var stepGraphEdges = [Edge<RecipeStepNode>]()
        record.stepEdges.forEach {
            let source = uuidToRecipeStepNodeMap[$0.sourceStepId]
            let destination = uuidToRecipeStepNodeMap[$0.destinationStepId]
            guard let sourceStepNode = source, let destinationStepNode = destination else {
                return
            }

            guard let edge = Edge<RecipeStepNode>(source: sourceStepNode, destination: destinationStepNode) else {
                return
            }
            stepGraphEdges.append(edge)
        }

        let stepGraph = (try? RecipeStepGraph(nodes: Array(uuidToRecipeStepNodeMap.values), edges: stepGraphEdges))
            ?? RecipeStepGraph()

        try self.init(
            id: id,
            userId: record.creatorId,
            parentOnlineRecipeId: record.parentOnlineRecipeId,
            name: record.name,
            servings: record.servings,
            difficulty: record.difficulty,
            cuisine: record.cuisine,
            stepGraph: stepGraph,
            ingredients: record.ingredients.compactMap({ try? RecipeIngredient(from: $0) }),
            ratings: record.ratings,
            createdAt: createdDate,
            updatedAt: updatedDate
        )
    }
}
