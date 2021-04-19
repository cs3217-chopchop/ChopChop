/**
 Represents a simple, directed, acyclic graph.
 
 Representation Invariants
 - There is at most one edge between any two nodes.
 - All edges are directed.
 - There are no cycles in the graph.
 */
class DirectedAcyclicGraph<N: Node>: Graph<N> {
    /**
     Initialises an empty DAG.
     */
    init() {
        super.init(isDirected: true)
    }

    /**
     Initialises a DAG with the given nodes and edges.

     - Throws:
        - `GraphError.repeatedEdge` if the given edges contain duplicates.
        - `DirectedAcyclicGraphError.addedEdgeFormsCycle` if the given edges form a cycle.
     */
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

    // MARK: - Edge Operations

    /**
     Checks whether the DAG contains an edge with the same source and destination node as the given edge.
     */
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

    /**
     Adds the given edge into the DAG, and its source and/or destination nodes if they do not exist in the DAG.

     - Throws:
        - `GraphError.repeatedEdge` if the given edge already exists in the DAG.
        - `DirectedAcyclicGraphError.addedEdgeFormsCycle`
            if the given edge would result in a cycle if added into the DAG.
     */
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

    private func isValidEdge(_ addedEdge: E) -> Bool {
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

        return !containsCycle
    }

    // MARK: - Invariance Checks

    /// Checks whether the current DAG contains a cycle.
    private var containsCycle: Bool {
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

        /// If current node is already in the path, there is a cycle.
        if nodesInPath[currentIdx] {
            return true
        }

        /// If current node is not in the path but has been visited, there is no cycle.
        if visitedNodes[currentIdx] {
            return false
        }

        /// Else the current node is not in the path and has not been visited. Continue traversal from the current node.
        /// Visit the current node
        visitedNodes[currentIdx] = true

        /// Add the current node into the path
        nodesInPath[currentIdx] = true

        /// Traverse depth first and check for cycles
        for idx in getIndexOfNodesAdjacent(to: nodes[currentIdx], nodes: nodes) {
            if containsCycleHelper(idx, nodes: nodes, visitedNodes: &visitedNodes, nodesInPath: &nodesInPath) {
                return true
            }
        }

        /// After traversing all nodes in the path starting from the current node, remove it from the path.
        nodesInPath[currentIdx] = false

        return false
    }

    /// Checks whether the current DAG is a simple graph.
    private var isSimpleGraph: Bool {
        var isSimpleGraph = true
        let stableEdges = edges

        for i in 0..<stableEdges.count {
            for j in i + 1..<stableEdges.count {
                isSimpleGraph = isSimpleGraph && !(stableEdges[i] ~= stableEdges[j])
            }
        }

        return isSimpleGraph
    }

    override internal func checkRepresentation() -> Bool {
        let allEdgesInCorrectList = adjacencyList.allSatisfy { node, edges in
            edges.allSatisfy { $0.source == node }
        }

        return allEdgesInCorrectList && isSimpleGraph && !containsCycle
    }

    // MARK: - Topological Sort

    /// The nodes in the graph sorted in topological order.
    /// - Important: The computed result of this property is not stable if there are multiple valid topological orders.
    var topologicallySortedNodes: [N] {
        let stableNodes = nodes
        let n = stableNodes.count

        var visitedNodes = Array(repeating: false, count: n)
        var nodeStack: [N] = []

        for currentIdx in 0..<n where !visitedNodes[currentIdx] {
            topologicalSortHelper(currentIdx, nodes: stableNodes, visitedNodes: &visitedNodes, nodeStack: &nodeStack)
        }

        /// Nodes must be reversed because post order DFS was used
        return nodeStack.reversed()
    }

    private func topologicalSortHelper(_ currentIdx: Int, nodes: [N],
                                       visitedNodes: inout [Bool], nodeStack: inout [N]) {
        let currentNode = nodes[currentIdx]

        /// Mark current node as visited
        visitedNodes[currentIdx] = true

        /// Traverse depth first
        for idx in getIndexOfNodesAdjacent(to: currentNode, nodes: nodes) where !visitedNodes[idx] {
            topologicalSortHelper(idx, nodes: nodes, visitedNodes: &visitedNodes, nodeStack: &nodeStack)
        }

        /// After all children have been traversed, push current node into stack
        nodeStack.append(currentNode)
    }

    private func getIndexOfNodesAdjacent(to sourceNode: N, nodes: [N]) -> [Int] {
        let adjacentNodes = getNodesAdjacent(to: sourceNode)

        return adjacentNodes.compactMap { nodes.firstIndex(of: $0) }
    }

    // MARK: - Layers

    /// An array of layers of nodes ordered such that all edges point from a higher to a lower layer.
    /// - Important: The computed result of this property is not stable if there are multiple valid layerings.
    var nodeLayers: [[N]] {
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
