import Foundation
import FirebaseFirestoreSwift

class OnlineRecipe: Identifiable {
    private(set) var id: String
    private(set) var userId: String
    private(set) var parentOnlineRecipeId: String?

    private(set) var name: String
    private(set) var servings: Double
    private(set) var cuisine: String?
    private(set) var difficulty: Difficulty?
    private(set) var stepGraph: RecipeStepGraph
    private(set) var ingredients: [RecipeIngredient]
    private(set) var ratings: [RecipeRating]
    private(set) var created: Date

    // swiftlint:disable function_default_parameter_at_end
    init(id: String, userId: String, parentOnlineRecipeId: String? = nil, name: String, servings: Double,
         difficulty: Difficulty?, cuisine: String?, stepGraph: RecipeStepGraph,
         ingredients: [RecipeIngredient], ratings: [RecipeRating], created: Date) throws {
        self.id = id
        self.userId = userId
        self.parentOnlineRecipeId = parentOnlineRecipeId
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }
        self.name = trimmedName

        guard servings > 0 else {
            throw RecipeError.invalidServings
        }
        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.stepGraph = stepGraph
        self.ingredients = ingredients
        self.ratings = ratings
        self.created = created
    }
    // swiftlint:enable function_default_parameter_at_end
}

extension OnlineRecipe {
    convenience init(from record: OnlineRecipeRecord) throws {
        guard let id = record.id else {
            throw OnlineRecipeRecordError.missingId
        }

        guard let createdDate = record.created else {
            throw OnlineRecipeRecordError.missingCreatedDate
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
            userId: record.creator,
            parentOnlineRecipeId: record.parentOnlineRecipeId,
            name: record.name,
            servings: record.servings,
            difficulty: record.difficulty,
            cuisine: record.cuisine,
            stepGraph: stepGraph,
            ingredients: record.ingredients.compactMap({ try? RecipeIngredient(from: $0) }),
            ratings: record.ratings,
            created: createdDate
        )
    }
}
