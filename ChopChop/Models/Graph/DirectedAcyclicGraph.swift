class DirectedAcyclicGraph<T: Hashable & Codable>: Graph<T> {
    init() {
        super.init(isDirected: true)
    }

    override func containsEdge(_ targetEdge: E) -> Bool {
        let sourceNode = targetEdge.source
        let destinationNode = targetEdge.destination

        guard let edgesFromSourceNode = adjacencyList[sourceNode] else {
            return false
        }

        return edgesFromSourceNode.contains {
            $0.source == sourceNode && $0.destination == destinationNode
        }
    }

    override func addEdge(_ addedEdge: E) throws {
        guard !containsEdge(addedEdge) else {
            throw GraphError.repeatedEdge
        }

        let sourceNode = addedEdge.source
        let destinationNode = addedEdge.destination

        guard containsNode(sourceNode) && containsNode(destinationNode) else {
            try super.addEdge(addedEdge)
            return
        }

        if var edgesFromSourceNode = adjacencyList[sourceNode] {
            edgesFromSourceNode.append(addedEdge)
            adjacencyList[sourceNode] = edgesFromSourceNode
        }

        guard !containsCycle() else {
            removeEdge(addedEdge)
            throw DirectedAcyclicGraphError.addedEdgeFormsCycle
        }
    }

    // MARK: - Cycles
    private func containsCycle() -> Bool {
        let stableNodes = nodes
        let n = stableNodes.count

        var visitedNodes = Array(repeating: false, count: n)
        var nodesInPath = Array(repeating: false, count: n)

        for i in 0..<n {
            if containsCycleHelper(i, nodes: stableNodes, visitedNodes: &visitedNodes, nodesInPath: &nodesInPath) {
                return true
            }
        }

        return false
    }

    private func containsCycleHelper(_ currentIdx: Int, nodes: [N], visitedNodes: inout [Bool], nodesInPath: inout [Bool]) -> Bool {
        // If current node is already in the path, cycle found.
        if nodesInPath[currentIdx] {
            return true
        }

        // If current node is not in path but has been visited, there is no cycle.
        if visitedNodes[currentIdx] {
            return false
        }

        // Visit the current node
        visitedNodes[currentIdx] = true

        // Add the current node into the path
        nodesInPath[currentIdx] = true

        // Traverse depth first and check for cycles
        for idx in getIndexOfNodesAdjacent(to: nodes[currentIdx], nodes: nodes) {
            if containsCycleHelper(idx, nodes: nodes, visitedNodes: &visitedNodes, nodesInPath: &nodesInPath) {
                return true
            }
        }

        // After traversing all nodes in the path starting from the current node, remove it from the path.
        nodesInPath[currentIdx] = false

        return false
    }

    // MARK: - Topological Sort
    func getTopologicallySortedNodes() -> [N] {
        let stableNodes = nodes
        let n = stableNodes.count

        var visitedNodes = Array(repeating: false, count: n)
        var nodeStack: [N] = []

        for currentIdx in 0..<n where !visitedNodes[currentIdx] {
            topologicalSortHelper(currentIdx, nodes: stableNodes, visitedNodes: &visitedNodes, nodeStack: &nodeStack)
        }

        // Nodes must be reversed because post order DFS is used
        return nodeStack.reversed()
    }

    private func topologicalSortHelper(_ currentIdx: Int, nodes: [N], visitedNodes: inout [Bool], nodeStack: inout [N]) {
        let currentNode = nodes[currentIdx]

        // Mark current node as visited
        visitedNodes[currentIdx] = true

        for idx in getIndexOfNodesAdjacent(to: currentNode, nodes: nodes) where !visitedNodes[idx] {
            topologicalSortHelper(currentIdx, nodes: nodes, visitedNodes: &visitedNodes, nodeStack: &nodeStack)
        }

        // After all children are traversed, push current node into stack
        nodeStack.append(currentNode)
    }

    private func getIndexOfNodesAdjacent(to sourceNode: N, nodes: [N]) -> [Int] {
        let adjacentNodes = getNodesAdjacent(to: sourceNode)

        return adjacentNodes.compactMap { nodes.firstIndex(of: $0) }
    }

    // MARK: - Layers
    func getNodeLayers() -> [[N]] {
        var nodeLayers: [[N]] = []

        var currentNodes = Set(nodes)
        var currentEdges = Set(edges)
        var currentLayer = getNodesWithoutIncomingEdges(nodes: currentNodes, edges: currentEdges)

        while !currentLayer.isEmpty {
            nodeLayers.append(Array(currentLayer))
            currentNodes.subtract(currentLayer)
            currentEdges = currentEdges.filter { !currentLayer.contains($0.source) }
            currentLayer = getNodesWithoutIncomingEdges(nodes: currentNodes, edges: currentEdges)
        }

        return nodeLayers
    }

    private func getNodesWithoutIncomingEdges(nodes: Set<N>, edges: Set<E>) -> Set<N> {
        let destinationNodes = Set(edges.map { $0.destination })
        return nodes.filter { !destinationNodes.contains($0) }
    }
}

enum DirectedAcyclicGraphError: Error {
    case addedEdgeFormsCycle
}
