import GRDB

class RecipeStepGraph: DirectedAcyclicGraph<RecipeStepNode>, FetchableRecord {
    var id: Int64?

    override init() {
        super.init()
    }

    override init(nodes: [RecipeStepNode], edges: [E]) throws {
        super.init()

        for node in nodes {
            self.addNode(node)
        }

        for edge in edges {
            try self.addEdge(edge)
        }

        assert(checkRepresentation())
    }

    required init(row: Row) {
        let stepRecords = row.prefetchedRows["recipeSteps"]?.compactMap {
            RecipeStepRecord(row: $0)
        }

        let steps = stepRecords?.compactMap {
            try? RecipeStep(content: $0.content)
        } ?? []

        let nodes = steps.map { RecipeStepNode($0) }

        let edges: [Edge<RecipeStepNode>] = row.prefetchedRows["recipeStepEdges"]?.compactMap {
            let record = RecipeStepEdgeRecord(row: $0)

            guard let sourceId = record.sourceId,
                  let destinationId = record.destinationId else {
                return nil
            }

            guard let sourceRecord = stepRecords?.first(where: { $0.id == sourceId }),
                  let destinationRecord = stepRecords?.first(where: { $0.id == destinationId }),
                  let sourceStep = try? RecipeStep(content: sourceRecord.content),
                  let destinationStep = try? RecipeStep(content: destinationRecord.content) else {
                return nil
            }

            return Edge<RecipeStepNode>(source: RecipeStepNode(sourceStep), destination: RecipeStepNode(destinationStep))
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
