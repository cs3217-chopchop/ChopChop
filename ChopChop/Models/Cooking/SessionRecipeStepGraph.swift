final class SessionRecipeStepGraph {
    private let graph: DirectedAcyclicGraph<SessionRecipeStepNode>

    var nodes: [SessionRecipeStepNode] {
        graph.nodes
    }

    var edges: [Edge<SessionRecipeStepNode>] {
        graph.edges
    }

    var topologicallySortedNodes: [SessionRecipeStepNode] {
        graph.topologicallySortedNodes
    }

    var nodeLayers: [[SessionRecipeStepNode]] {
        graph.nodeLayers
    }

    var hasTimers: Bool {
        !nodes.allSatisfy { $0.label.timers.isEmpty }
    }

    var isCompleted: Bool {
        nodes.allSatisfy { $0.isCompleted }
    }

    init() {
        graph = DirectedAcyclicGraph<SessionRecipeStepNode>()
    }

    init(graph: RecipeStepGraph) throws {
        let sessionNodes: [RecipeStepNode: SessionRecipeStepNode] = graph.nodes.reduce(into: [:], { nodes, node in
            let sessionNode = SessionRecipeStepNode(node: node)

            nodes[node] = sessionNode
        })

        let sessionEdges: [Edge<SessionRecipeStepNode>] = graph.edges.compactMap {
            guard let sourceNode = sessionNodes[$0.source], let destinationNode = sessionNodes[$0.destination] else {
                return nil
            }

            return Edge(source: sourceNode, destination: destinationNode)
        }

        self.graph = try DirectedAcyclicGraph(nodes: Array(sessionNodes.values), edges: sessionEdges)
        updateNodes()
    }

    func toggleNode(_ node: SessionRecipeStepNode) {
        guard graph.containsNode(node) else {
            return
        }

        node.isCompleted.toggle()
        updateNodes()
    }

    private func updateNodes() {
        for node in graph.topologicallySortedNodes {
            let areSourcesCompleted = edges.filter { $0.destination == node }.allSatisfy { $0.source.isCompleted }

            node.isCompletable = areSourcesCompleted

            if !areSourcesCompleted {
                node.isCompleted = false
            }
        }
    }
}
