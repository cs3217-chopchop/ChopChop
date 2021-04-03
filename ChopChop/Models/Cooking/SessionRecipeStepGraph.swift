class SessionRecipeStepGraph {
    private let graph: DirectedAcyclicGraph<SessionRecipeStepNode>
    private let actionTimeTracker: ActionTimeTracker

    var nodes: [SessionRecipeStepNode] {
        graph.nodes
    }

    var edges: [Edge<SessionRecipeStepNode>] {
        graph.edges
    }

    init?(graph: RecipeStepGraph) {
        let actionTimeTracker = ActionTimeTracker()

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

        self.actionTimeTracker = actionTimeTracker
        self.graph = sessionGraph

        updateCompletableNodes()
    }

    func getTopologicallySortedNodes() -> [SessionRecipeStepNode] {
        graph.getTopologicallySortedNodes()
    }

    func getNodeLayers() -> [[SessionRecipeStepNode]] {
        graph.getNodeLayers()
    }

    private func updateCompletableNodes() {
        for node in graph.getTopologicallySortedNodes() {
            let sourcesAreCompleted = edges.filter({ $0.destination == node }).allSatisfy({ $0.source.isCompleted })

            node.isCompletable = sourcesAreCompleted
            node.isCompleted = sourcesAreCompleted ? node.isCompleted : false
        }
    }

    func resetSteps() {
        graph.nodes.forEach { node in
            node.isCompletable = false
            node.isCompleted = false
        }

        updateCompletableNodes()
    }

    func toggleStep(_ node: SessionRecipeStepNode) {
        node.isCompleted.toggle()
        updateCompletableNodes()
    }
}
