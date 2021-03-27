class SessionRecipeStepGraph: DirectedAcyclicGraph<SessionRecipeStepNode> {
    override init() {
        super.init()
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
