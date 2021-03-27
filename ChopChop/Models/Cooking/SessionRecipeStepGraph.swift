class SessionRecipeStepGraph: DirectedAcyclicGraph<SessionRecipeStepNode> {
    override init() {
        super.init()
    }

    init?(graph: RecipeStepGraph) {
        super.init()

        let sessionNodes = graph.nodes.map { SessionRecipeStepNode($0) }

        for node in sessionNodes {
            self.addNode(node)
        }

        for edge in graph.edges {
            guard let sessionSourceNode = sessionNodes.first(where: { $0.label == edge.source.label }),
                  let sessionDestinationNode = sessionNodes.first(where: { $0.label == edge.destination.label }),
                  let sessionEdge = E(source: sessionSourceNode, destination: sessionDestinationNode) else {
                return nil
            }

            do {
                try self.addEdge(sessionEdge)
            } catch {
                return nil
            }
        }
    }

    override func addNode(_ addedNode: SessionRecipeStepNode) {
        super.addNode(addedNode)
        updateCompletableNodes()
    }

    override func removeNode(_ removedNode: SessionRecipeStepNode) {
        super.removeNode(removedNode)
        updateCompletableNodes()
    }

    override func addEdge(_ addedEdge: E) throws {
        try super.addEdge(addedEdge)
        updateCompletableNodes()
    }

    override func removeEdge(_ removedEdge: E) {
        super.removeEdge(removedEdge)
        updateCompletableNodes()
    }

    func getCompletableNodes() -> Set<SessionRecipeStepNode> {
        let destinationNodes = Set(edges
            .filter { !$0.source.isCompleted }
            .map { $0.destination })

        return Set(
            nodes.filter { node in
                !node.isCompleted && !destinationNodes.contains(node)
            })
    }

    private func updateCompletableNodes() {
        let completableNodes = getCompletableNodes()
        completableNodes.forEach { $0.isCompletable = true }
    }

    func resetSteps() {
        nodes.forEach { node in
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
