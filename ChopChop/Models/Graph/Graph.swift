class Graph<T: Hashable & Codable> {
    typealias N = Node<T>
    typealias E = Edge<T>

    let isDirected: Bool

    internal var adjacencyList: [N: [E]]

    init(isDirected: Bool) {
        self.isDirected = isDirected
        self.adjacencyList = [:]
    }

    // MARK: - Nodes
    var nodes: [N] {
        Array(adjacencyList.keys)
    }

    func containsNode(_ targetNode: N) -> Bool {
        adjacencyList[targetNode] != nil
    }

    func addNode(_ addedNode: N) {
        guard !containsNode(addedNode) else {
            return
        }

        adjacencyList[addedNode] = []
    }

    func removeNode(_ removedNode: N) {
        adjacencyList[removedNode] = nil

        let edgesToRemovedNode = edges.filter { $0.destination == removedNode }

        edgesToRemovedNode.forEach { removeEdge($0) }
    }

    func getNodesAdjacent(to sourceNode: N) -> [N] {
        guard let edgesFromNode = adjacencyList[sourceNode] else {
            return []
        }

        var setOfAdjacentNodes: Set<N> = []
        var adjacentNodes: [N] = []

        for edge in edgesFromNode {
            let adjacentNode = edge.destination

            guard !setOfAdjacentNodes.contains(adjacentNode) else {
                continue
            }

            setOfAdjacentNodes.insert(adjacentNode)
            adjacentNodes.append(adjacentNode)
        }

        return adjacentNodes
    }

    // MARK: - Edges
    var edges: [E] {
        adjacencyList.values.reduce(into: [], +=)
    }

    func containsEdge(_ targetEdge: E) -> Bool {
        let sourceNode = targetEdge.source

        guard let edgesFromSourceNode = adjacencyList[sourceNode] else {
            return false
        }

        return edgesFromSourceNode.contains(targetEdge)
    }

    func removeEdge(_ removedEdge: E) {
        removeSingleEdge(removedEdge)

        if !isDirected {
            let reversedEdge = removedEdge.reversed()
            removeSingleEdge(reversedEdge)
        }
    }

    private func removeSingleEdge(_ removedEdge: E) {
        let sourceNode = removedEdge.source

        // If the source node is not a key in the adjacency list, the edge does not exist in the graph.
        guard var edgesFromSourceNode = adjacencyList[sourceNode] else {
            return
        }

        edgesFromSourceNode.removeAll { $0 == removedEdge }
        adjacencyList[sourceNode] = edgesFromSourceNode
    }

    func addEdge(_ addedEdge: E) throws {
        guard !containsEdge(addedEdge) else {
            throw GraphError.repeatedEdge
        }

        let sourceNode = addedEdge.source
        let destinationNode = addedEdge.destination
        addNode(sourceNode)
        addNode(destinationNode)

        if var edgesFromSourceNode = adjacencyList[sourceNode] {
            edgesFromSourceNode.append(addedEdge)
            adjacencyList[sourceNode] = edgesFromSourceNode
        }

        if !isDirected {
            let reversedEdge = addedEdge.reversed()

            // This guards against adding duplicate edges when added edge is a loop.
            guard !containsEdge(reversedEdge) else {
                return
            }

            if var edgesFromDestinationNode = adjacencyList[destinationNode] {
                edgesFromDestinationNode.append(reversedEdge)
                adjacencyList[destinationNode] = edgesFromDestinationNode
            }
        }
    }
}

enum GraphError: Error {
    case repeatedEdge
}
