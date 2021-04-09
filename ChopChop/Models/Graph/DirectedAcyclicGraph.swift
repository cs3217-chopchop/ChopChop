/**
 The `DirectedAcyclicGraph` ADT is able to represent a simple, directed, acyclic graph.
 
 The representation invariants for a DAG g are:
 - g is a simple graph (multiple edges with the same source and destination node not allowed)
 - g is a directed graph
 - g is acyclic (does not contain a cycle)
 */
class DirectedAcyclicGraph<N: Node>: Graph<N> {
    init() {
        super.init(isDirected: true)
    }

    init(nodes: [N], edges: [E]) throws {
        super.init(isDirected: true)

        for node in nodes {
            self.addNode(node)
        }

        for edge in edges {
            try self.addEdge(edge)
        }

        assert(checkRepresentation())
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

        guard isValidEdge(addedEdge) else {
            throw DirectedAcyclicGraphError.addedEdgeFormsCycle
        }

        try super.addEdge(addedEdge)

        assert(checkRepresentation())
    }

    func isValidEdge(_ addedEdge: E) -> Bool {
        guard !containsEdge(addedEdge) else {
            return false
        }

        let sourceNode = addedEdge.source
        let destinationNode = addedEdge.destination

        guard containsNode(sourceNode) && containsNode(destinationNode),
              var edgesFromSourceNode = adjacencyList[sourceNode] else {
            return true
        }

        edgesFromSourceNode.append(addedEdge)
        adjacencyList[sourceNode] = edgesFromSourceNode

        defer {
            edgesFromSourceNode.removeAll { $0 == addedEdge }
            adjacencyList[sourceNode] = edgesFromSourceNode
        }

        return !containsCycle()
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

    private func containsCycleHelper(
        _ currentIdx: Int,
        nodes: [N],
        visitedNodes: inout [Bool],
        nodesInPath: inout [Bool]) -> Bool {

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
    var topologicallySortedNodes: [N] {
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

    private func topologicalSortHelper(_ currentIdx: Int, nodes: [N],
                                       visitedNodes: inout [Bool], nodeStack: inout [N]) {
        let currentNode = nodes[currentIdx]

        // Mark current node as visited
        visitedNodes[currentIdx] = true

        for idx in getIndexOfNodesAdjacent(to: currentNode, nodes: nodes) where !visitedNodes[idx] {
            topologicalSortHelper(idx, nodes: nodes, visitedNodes: &visitedNodes, nodeStack: &nodeStack)
        }

        // After all children are traversed, push current node into stack
        nodeStack.append(currentNode)
    }

    private func getIndexOfNodesAdjacent(to sourceNode: N, nodes: [N]) -> [Int] {
        let adjacentNodes = getNodesAdjacent(to: sourceNode)

        return adjacentNodes.compactMap { nodes.firstIndex(of: $0) }
    }

    override internal func checkRepresentation() -> Bool {
        let allEdgesInCorrectList = adjacencyList.allSatisfy { node, edges in
            edges.allSatisfy { $0.source == node }
        }

        return allEdgesInCorrectList && isSimpleGraph() && !containsCycle()
    }

    private func isSimpleGraph() -> Bool {
        var isSimpleGraph = true
        let stableEdges = edges

        for i in 0..<stableEdges.count {
            for j in i + 1..<stableEdges.count {
                isSimpleGraph = isSimpleGraph && !(stableEdges[i] ~= stableEdges[j])
            }
        }

        return isSimpleGraph
    }
}

enum DirectedAcyclicGraphError: Error {
    case addedEdgeFormsCycle
}
