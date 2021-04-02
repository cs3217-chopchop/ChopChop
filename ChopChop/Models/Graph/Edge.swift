struct Edge<N: Node>: Hashable {
    let source: N
    let destination: N
    let weight: Double

    init?(source: N, destination: N) {
        self.init(source: source, destination: destination, weight: 1.0)
    }

    init?(source: N, destination: N, weight: Double) {
        guard weight >= 0 else {
            return nil
        }

        self.source = source
        self.destination = destination
        self.weight = weight
    }

    func reversed() -> Edge<N> {
        guard let reversedEdge = Edge(source: destination, destination: source, weight: weight) else {
            fatalError("Current edge is invalid")
        }

        return reversedEdge
    }

    static func ~= (left: Edge<N>, right: Edge<N>) -> Bool {
        left.source == right.source && left.destination == right.destination
    }
}
