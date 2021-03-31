class SessionRecipeStepGraph {
    private let graph: DirectedAcyclicGraph<SessionRecipeStepNode>
    private let actionTimeTracker: ActionTimeTracker

    var nodes: [SessionRecipeStepNode] {
        graph.nodes
    }

    var edges: [Edge<SessionRecipeStepNode>] {
        graph.edges
    }

    var completableNodes: Set<SessionRecipeStepNode> {
        let notCompletedDestinationNodes = Set(graph.edges
            .filter { !$0.source.isCompleted }
            .map { $0.destination })

        return Set(
            graph.nodes.filter { node in
                !node.isCompleted && !notCompletedDestinationNodes.contains(node)
            }
        )
    }

    init?(graph: RecipeStepGraph) {
        self.actionTimeTracker = ActionTimeTracker()

        let sessionNodes = graph.nodes.map { SessionRecipeStepNode($0, actionTimeTracker: actionTimeTracker) }
        let sessionEdges = graph.edges.compactMap { edge -> Edge<SessionRecipeStepNode>? in
            guard let sessionSourceNode = sessionNodes.first(where: { $0.label.step == edge.source.label }),
                  let sessionDestinationNode = sessionNodes.first(where: { $0.label.step == edge.destination.label }),
                  let sessionEdge = Edge<SessionRecipeStepNode>(source: sessionSourceNode, destination: sessionDestinationNode) else {
                return nil
            }

            return sessionEdge
        }

        guard sessionEdges.count == graph.edges.count else {
            return nil
        }

        guard let sessionGraph = try? DirectedAcyclicGraph<SessionRecipeStepNode>(nodes: sessionNodes, edges: sessionEdges) else {
            return nil
        }

        self.graph = sessionGraph
    }

    private func updateCompletableNodes() {
        let completableNodes = getCompletableNodes()
        completableNodes.forEach { $0.isCompletable = true }
    }

    func resetSteps() {
        graph.nodes.forEach { node in
            node.isCompletable = false
            node.isCompleted = false
        }

        updateCompletableNodes()
    }

    func completeStep(_ node: SessionRecipeStepNode) {
        node.isCompleted = true
        updateCompletableNodes()
    }
}
