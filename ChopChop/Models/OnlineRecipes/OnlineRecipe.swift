import Foundation
import FirebaseFirestoreSwift

class OnlineRecipe: Identifiable {
    private(set) var id: String
    private(set) var userId: String

    private(set) var name: String
    private(set) var servings: Double
    private(set) var cuisine: String?
    private(set) var difficulty: Difficulty?
    private(set) var stepGraph: RecipeStepGraph
    private(set) var ingredients: [RecipeIngredient]
    private(set) var ratings: [RecipeRating]
    let createdAt: Date
    let updatedAt: Date

    init(id: String, userId: String, name: String, servings: Double,
         difficulty: Difficulty?, cuisine: String?, stepGraph: RecipeStepGraph,
         ingredients: [RecipeIngredient], ratings: [RecipeRating],
         created: Date, updatedAt: Date) throws {
        self.id = id
        self.userId = userId
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
        self.createdAt = created
        self.updatedAt = updatedAt
    }
}

extension OnlineRecipe {
    convenience init(from record: OnlineRecipeRecord, info: OnlineRecipeInfoRecord) throws {
        guard let id = record.id else {
            throw OnlineRecipeRecordError.missingId
        }

        // TODO push everything to info
        guard let createdDate = info.createdAt else {
            throw OnlineRecipeRecordError.missingCreatedDate
        }

        guard let updatedDate = info.updatedAt else {
            throw OnlineRecipeRecordError.missingUpdatedDate
        }

        let stepGraphNodes = try record.steps.compactMap({
            try RecipeStep(content: $0)
        })
        .map({
            RecipeStepNode($0)
        })

        var stepGraphEdges = [Edge<RecipeStepNode>]()
        record.stepEdges.forEach {
            var source: RecipeStep?
            var destination: RecipeStep?
            for node in stepGraphNodes {
                if source == nil && node.label.content == $0.sourceStep {
                    source = node.label
                } else if destination == nil && node.label.content == $0.destinationStep {
                    destination = node.label
                }
                if source != nil && destination != nil {
                    break
                }
            }
            guard let sourceStep = source, let destinationStep = destination else {
                return
            }

            let stepNodeSource = RecipeStepNode(sourceStep)
            let stepNodeDestination = RecipeStepNode(destinationStep)
            guard let edge = Edge<RecipeStepNode>(source: stepNodeSource, destination: stepNodeDestination) else {
                return
            }
            stepGraphEdges.append(edge)
        }

        let stepGraph = (try? RecipeStepGraph(nodes: stepGraphNodes, edges: stepGraphEdges)) ?? RecipeStepGraph()

        try self.init(
            id: id,
            userId: record.creator,
            name: record.name,
            servings: record.servings,
            difficulty: record.difficulty,
            cuisine: record.cuisine,
            stepGraph: stepGraph,
            ingredients: record.ingredients.compactMap({ try? RecipeIngredient(from: $0) }),
            ratings: record.ratings,
            created: createdDate,
            updatedAt: updatedDate
        )
    }
}
