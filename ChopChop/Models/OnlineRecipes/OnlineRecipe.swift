import Foundation

struct OnlineRecipe: Identifiable, CachableEntity {
    let id: String
    let creatorId: String
    let parentOnlineRecipeId: String?
    let name: String
    let servings: Double
    let cuisine: String?
    let difficulty: Difficulty?
    let stepGraph: RecipeStepGraph
    let ingredients: [RecipeIngredient]
    let ratings: [RecipeRating]
    let createdAt: Date
    let updatedAt: Date

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

extension OnlineRecipe {
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
