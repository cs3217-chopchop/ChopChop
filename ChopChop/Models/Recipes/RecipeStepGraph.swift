import Foundation
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

        var nodeIds: [UUID: Int64?] = [:]

        let nodes: [RecipeStepNode] = stepRecords?.compactMap {
            guard let step = try? RecipeStep($0.content) else {
                return nil
            }

            let node = RecipeStepNode(step)
            nodeIds[node.id] = $0.id

            return node
        } ?? []

        let edges: [Edge<RecipeStepNode>] = row.prefetchedRows["recipeStepEdges"]?.compactMap {
            let record = RecipeStepEdgeRecord(row: $0)

            guard let sourceNode = nodes.first(where: { nodeIds[$0.id, default: nil] == record.sourceId }),
                  let destinationNode = nodes.first(where: { nodeIds[$0.id, default: nil] == record.destinationId })
            else {
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
