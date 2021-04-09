import Foundation
import GRDB

final class RecipeStepGraph: DirectedAcyclicGraph<RecipeStepNode>, FetchableRecord {
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

    init(row: Row) {
        let nodes: [Int64?: RecipeStepNode] = row.prefetchedRows["recipeSteps"]?.reduce(into: [:], { nodes, row in
            let record = RecipeStepRecord(row: row)

            guard let step = try? RecipeStep(record.content) else {
                return
            }

            nodes?[record.id] = RecipeStepNode(step)
        }) ?? [:]

        let edges: [Edge<RecipeStepNode>] = row.prefetchedRows["recipeStepEdges"]?.compactMap {
            let record = RecipeStepEdgeRecord(row: $0)

            guard let sourceNode = nodes[record.sourceId], let destinationNode = nodes[record.destinationId] else {
                return nil
            }

            return Edge<RecipeStepNode>(source: sourceNode, destination: destinationNode)
        } ?? []

        super.init()

        for node in nodes.values {
            adjacencyList[node] = []
        }

        for edge in edges {
            adjacencyList[edge.source, default: []].append(edge)
        }

        assert(checkRepresentation())
    }
}
