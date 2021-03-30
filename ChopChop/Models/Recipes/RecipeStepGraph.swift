import GRDB

class RecipeStepGraph: DirectedAcyclicGraph<RecipeStepNode>, FetchableRecord {
    var id: Int64?

    override init() {
        super.init()
    }

    required init(row: Row) {
        let steps = row.prefetchedRows["recipeSteps"]?.compactMap {
            try? RecipeStep(content: RecipeStepRecord(row: $0).content)
        } ?? []
        let nodes = steps.map { RecipeStepNode($0) }

        let edges: [Edge<RecipeStepNode>] = row.prefetchedRows["recipeStepEdges"]?.compactMap {
            let record = RecipeStepEdgeRecord(row: $0)

            guard let sourceId = record.sourceId,
                  let destinationId = record.destinationId else {
                return nil
            }

            guard let sourceNode = nodes.first(where: { $0.label.id == sourceId }),
                  let destinationNode = nodes.first(where: { $0.label.id == destinationId }) else {
                return nil
            }

            return Edge<RecipeStepNode>(source: sourceNode, destination: destinationNode)
        } ?? []

        super.init()

        for node in nodes {
            adjacencyList[node] = []
        }

        for edge in edges {
            if var edgesFromSourceNode = adjacencyList[edge.source] {
                edgesFromSourceNode.append(edge)
                adjacencyList[edge.source] = edgesFromSourceNode
            }
        }

        assert(checkRepresentation())
    }
}
