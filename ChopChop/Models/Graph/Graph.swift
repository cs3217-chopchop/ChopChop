/**
 Represents a graph that consists of:
 - objects conforming to `Node`
 - zero or more `Edge`s joining the `Node`s
 
 It can represent the following graph types with corresponding constraints:
 - Undirected graph
   - An undirected edge is represented by 2 directed edges
 - Directed graph
 - Simple graph
 - Multigraph
   - Edges from the same source to the same destination should have different weight
 - Unweighted graph
   - Edges' weights are to set to 1.0
 - Weighted graph

 Representation Invariants:
 - The graph is either directed or undirected
    - In an undirected graph, edges should come in pairs (their reverse)) except for loops.
 - All nodes must have unique labels.
 - Multiple edges with the same source and destination nodes must not have the same weight.
 */
class Graph<N: Node> {
    typealias E = Edge<N>

    // MARK: - Specification Fields
    /// Represents whether the graph is directed or undirected.
    let isDirected: Bool

    internal var adjacencyList: [N: [E]]

    /**
     Initialises an empty directed or undirected graph according to the given flag.
     */
    init(isDirected: Bool) {
        self.isDirected = isDirected
        self.adjacencyList = [:]
    }

    /**
     Initialises a directed or undirected graph containing the given nodes and edges.
     Fails if the given nodes and edges do not result in a valid graph.
     */
    convenience init?(isDirected: Bool, nodes: [N], edges: [E]) {
        self.init(isDirected: isDirected)

        for node in nodes {
            self.addNode(node)
        }

        for edge in edges {
            try? self.addEdge(edge)
        }

        assert(checkRepresentation())
    }

    // MARK: - Node Operations

    /// The nodes in the graph.
    var nodes: [N] {
        Array(adjacencyList.keys)
    }

    /**
     Checks whether the graph contains the given node.
     */
    func containsNode(_ targetNode: N) -> Bool {
        adjacencyList[targetNode] != nil
    }

    /**
     Adds the given node into the graph.
     If the node already exists, do nothing.
     */
    func addNode(_ addedNode: N) {
        guard !containsNode(addedNode) else {
            return
        }

        adjacencyList[addedNode] = []
    }

    /**
     Removes the given node from the graph, removing all incoming and outgoing edges.
     If the graph does not contain the node, do nothing.
     */
    func removeNode(_ removedNode: N) {
        adjacencyList[removedNode] = nil

        let edgesToRemovedNode = edges.filter { $0.destination == removedNode }

        edgesToRemovedNode.forEach { removeEdge($0) }

        assert(checkRepresentation())
    }

    /**
     Returns the nodes adjacent to the given node.
     If the graph does not contain the node, returns an empty array.
     */
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

    // MARK: - Edge Operations

    /// The edges in the graph.
    var edges: [E] {
        adjacencyList.values.reduce(into: [], +=)
    }

    /**
     Checks whether the graph contains the given edge.
     */
    func containsEdge(_ targetEdge: E) -> Bool {
        let sourceNode = targetEdge.source

        guard let edgesFromSourceNode = adjacencyList[sourceNode] else {
            return false
        }

        return edgesFromSourceNode.contains(targetEdge)
    }

    /**
     Removes the given edge from the graph.
     If the graph does not contain the edge, do nothing.
     */
    func removeEdge(_ removedEdge: E) {
        removeSingleEdge(removedEdge)

        if !isDirected {
            let reversedEdge = removedEdge.reversed
            removeSingleEdge(reversedEdge)
        }
    }

    private func removeSingleEdge(_ removedEdge: E) {
        let sourceNode = removedEdge.source

        /// If the source node is not a key in the adjacency list, the edge does not exist in the graph.
        guard var edgesFromSourceNode = adjacencyList[sourceNode] else {
            return
        }

        edgesFromSourceNode.removeAll { $0 == removedEdge }
        adjacencyList[sourceNode] = edgesFromSourceNode

        assert(checkRepresentation())
    }

    /**
     Adds the given edge into the graph, and its source and/or destination nodes if they do not exist in the graph.

     - Throws: `GraphError.repeatedEdge` if the given edge already exists in the graph.
     */
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
            let reversedEdge = addedEdge.reversed

            /// Do not add duplicate edges when added edge is a loop.
            guard !containsEdge(reversedEdge) else {
                return
            }

            if var edgesFromDestinationNode = adjacencyList[destinationNode] {
                edgesFromDestinationNode.append(reversedEdge)
                adjacencyList[destinationNode] = edgesFromDestinationNode
            }
        }

        assert(checkRepresentation())
    }

    internal func checkRepresentation() -> Bool {
        let allEdgesInCorrectList = adjacencyList.allSatisfy { node, edges in
            edges.allSatisfy { $0.source == node }
        }

        let noIdenticalEdges = edges.count == Set(edges).count

        return allEdgesInCorrectList && noIdenticalEdges
    }
}

extension Graph: Equatable {
    private struct EquatableEdge: Hashable {
        let source: N.T
        let destination: N.T
        let weight: Double
    }

    static func == (lhs: Graph<N>, rhs: Graph<N>) -> Bool {
        let leftNodes = Set(lhs.nodes.map { $0.label })
        let rightNodes = Set(rhs.nodes.map { $0.label })
        let areNodesEqual = leftNodes == rightNodes

        let leftEdges = Set(lhs.edges.map {
            EquatableEdge(
                source: $0.source.label,
                destination: $0.destination.label,
                weight: $0.weight)
        })
        let rightEdges = Set(rhs.edges.map {
            EquatableEdge(
                source: $0.source.label,
                destination: $0.destination.label,
                weight: $0.weight)
        })
        let areEdgesEqual = leftEdges == rightEdges

        return areNodesEqual && areEdgesEqual
    }
}

enum GraphError: Error {
    case repeatedEdge
}
