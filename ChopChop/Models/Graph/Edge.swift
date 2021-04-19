/**
 Represents an edge between two nodes in a graph.
 
 Representation Invariants:
 - An edge is either weighted or unweighted (weight set to 1.0).
 - The weight of an edge is non negative.
 */
struct Edge<N: Node>: Hashable {

    // MARK: - Specification Fields
    /// The source node of the edge.
    let source: N
    /// The destination node of the edge.
    let destination: N
    /// The weight of the edge.
    let weight: Double

    /**
     Initialises an unweighted edge with the given source and destination nodes.
     */
    init?(source: N, destination: N) {
        self.init(source: source, destination: destination, weight: 1.0)
    }

    /**
     Initialises a weighted edge with the given source and destination nodes and weight.
     */
    init?(source: N, destination: N, weight: Double) {
        guard weight >= 0 else {
            return nil
        }

        self.source = source
        self.destination = destination
        self.weight = weight
    }

    /// The reverse of the edge, with the same weight.
    var reversed: Edge<N> {
        guard let reversedEdge = Edge(source: destination, destination: source, weight: weight) else {
            fatalError("Current edge is invalid")
        }

        return reversedEdge
    }

    /**
     Returns whether the left and right edges share the same source and destination nodes.
     */
    static func ~= (left: Edge<N>, right: Edge<N>) -> Bool {
        left.source == right.source && left.destination == right.destination
    }
}
