import Foundation
import GRDB

/**
 Represents a graph that models the instructions to make a recipe.
 
 Representation Invariants:
 - The graph fulfills the invariants of `DirectedAcyclicGraph`.
 */
final class RecipeStepGraph: DirectedAcyclicGraph<RecipeStepNode> {
    /**
     Initialises an empty graph.
     */
    override init() {
        super.init()
    }

    /**
     Initialises a graph with the given nodes and edges.

     - Throws:
        - `GraphError.repeatedEdge` if the given edges contain duplicates.
        - `DirectedAcyclicGraphError.addedEdgeFormsCycle` if the given edges form a cycle.
     */
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
}

extension RecipeStepGraph: FetchableRecord {
    convenience init(row: Row) {
        self.init()

        let nodes: [Int64?: RecipeStepNode] = row.prefetchedRows["recipeSteps"]?.reduce(into: [:], { nodes, row in
            let record = RecipeStepRecord(row: row)
            let timers: [TimeInterval] = row.prefetchedRows["recipeStepTimers"]?.map {
                let record = RecipeStepTimerRecord(row: $0)

                return record.duration
            } ?? []

            guard let step = try? RecipeStep(record.content, timers: timers) else {
                return
            }

            nodes?[record.id] = RecipeStepNode(step)
        }) ?? [:]

        let edges: [Edge<RecipeStepNode>] = row.prefetchedRows["recipeStepEdges"]?.compactMap {
            let record = RecipeStepEdgeRecord(row: $0)

            guard let sourceNode = nodes[record.sourceId], let destinationNode = nodes[record.destinationId] else {
                return nil
            }

            return Edge(source: sourceNode, destination: destinationNode)
        } ?? []

        for node in nodes.values {
            adjacencyList[node] = []
        }

        for edge in edges {
            adjacencyList[edge.source, default: []].append(edge)
        }

        assert(checkRepresentation())
    }
}

extension RecipeStepGraph {
    func copy() -> RecipeStepGraph? {
        // [Original: Copied]
        let copiedNodes: [RecipeStepNode: RecipeStepNode] = nodes.reduce(into: [:], { nodes, node in
            let copiedNode = RecipeStepNode(node.label)

            nodes[node] = copiedNode
        })

        let copiedEdges: [Edge<RecipeStepNode>] = edges.compactMap {
            guard let sourceNode = copiedNodes[$0.source], let destinationNode = copiedNodes[$0.destination] else {
                return nil
            }

            return Edge(source: sourceNode, destination: destinationNode)
        }

        return try? RecipeStepGraph(nodes: Array(copiedNodes.values), edges: copiedEdges)
    }
}
